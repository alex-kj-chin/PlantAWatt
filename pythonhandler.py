from mod_python import apache
import xml.etree.ElementTree as ET
import MySQLdb as mdb #import the mysql library
import json
import sys
import time
results = {} #dictionary
results['requests'] = []

def handler(req):
    initial_request = req.read() #json.loads(req.read())
    request = json.loads(initial_request)
    req_type = request["typeage"]
    SAIDphone = request["SAID"]
    PINphone = request["PIN"]
    todo = request["todo"]
    try: #This is a try statement
        conobjectmysql = mdb.connect('localhost', 'PGEserver', 'greenbird42', 'PlantAWattSchema') #This creates a variable that has an interface to the database in it.
        cursor = conobjectmysql.cursor() #This makes variable cursor equal to a cursor object, an object that holds the  querry results
        cursor.execute('SELECT PIN FROM Users WHERE SAID = %s', (SAIDphone))
        serverPIN = cursor.fetchall()
        if serverPIN[0][0] == PINphone:
                cursor.execute('SELECT id FROM Users WHERE SAID = %s', (SAIDphone))
                customerid = cursor.fetchall()[0][0]
                if req_type == "update":
                        for Every in todo:
                                cursor.execute('SELECT money, energy FROM Users WHERE username = %s', Every)
                                m_e = cursor.fetchall()[0]
                                results[Every] = m_e
                if req_type == "friendRequest":
                        cursor.execute('SELECT id FROM Users WHERE username = %s', todo)
                        customerfriendid = cursor.fetchall()[0][0]
                        print >> open("/home/ubuntu/smartphonefiles/test4.txt", "w"), customerfriendid
                        cursor.execute('SELECT * FROM Friends WHERE friend1 = %s OR friend2 = %s', (customerfriendid, customerfriendid))
                        already = cursor.fetchall()[0]
                        if already == []:
                                print >> open("/home/ubuntu/smartphonefiles/test3.txt", "w"), "newFriend"
                                cursor.execute('INSERT INTO Friends (friend1, friend2, accepted) VALUES(%s, %s, 0)', (customerid, customerfriendid))
                                conobjectmysql.commit()
                                results['friendRequest'] = "A request has been sent."
                        else:
                                print >> open("/home/ubuntu/smartphonefiles/test2.txt", "w"), str(already[0])
                                if int(already[0]) == customerid:
                                        if int(already[2]) == 1:
                                                results['friendRequest'] = 'You guys are already friends'
                                        elif int( already[2]) == 0:
                                                results['friendRequest'] = 'You have already sent a request. Waiting for your friend to accept.'
                               elif int(already[1]) == customerid:
                                        results['friendRequest'] = 'Looks like this person sent you a friend request. Please look at the people who want to be your friend.'
                                        results['requests'].append(already[0])
        cursor.execute('SELECT * FROM Friends WHERE friend2 = %s', customerid)
        ppl_req = cursor.fetchall()
        for Each in ppl_req:
                if Each[2] == 0:
                        cursor.execute('SELECT * FROM Friends WHERE friend1 = %s AND friend2 = %s', (customerid, Each[0]))
                        temporary = cursor.fetchall()
                        if temporary == []:
                                cursor.execute('SELECT username FROM Users WHERE id = %s', Each[0])
                                temporary = cursor.fetchall()
                                results['requests'].append(temporary)
        print >> open("/home/ubuntu/smartphonefiles/test.txt", "w"), results
        req.write(json.dumps(results))
    except mdb.Error, e: #This puts in an exception if there is an error
        print >> open("/home/ubuntu/smartphonefiles/error.txt", "w"), "Error %d: %s" % (e.args[0], e.args[1])
        sys.exit(1) #Then exit out of this program (do not run the finally statement)
    finally: #And finally do the following
        if conobjectmysql:
                conobjectmysql.close() #Close the connection if it is still open
    return apache.OK

                                                                                                                                                                 70,0-1        Bot
