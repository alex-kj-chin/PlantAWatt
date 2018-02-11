import httplib, urllib #this imports the library to contact the PG&E server
import datetime #This import the library to put times on stuff
import xml.etree.ElementTree as ET #This imports the library to insert stuff into the XML files
import MySQLdb as mdb  #This imports the mysql database
import sys #This allows this script to make system calls (in this case to shut down the whole program in case of an error)
import time #imports time so that delays can be implemented
SAID, PIN, Username  = "", "", "" #This sets global variables SAID, PIN, Username


def xmleditorpge(PIN, SAID, Username):
        tree = ET.parse('testrequest.xml')#This part parses the "tree" or testrequest.xml
        root = tree.getroot() #This gets the first node
        timeneeded = datetime.datetime.today().strftime("%Y%m%d%H%M%S") #This assigns a date and time value to timeneeded
        id = root[0] #we are indexing the XML file for the id tag. This assumes that id  is the first tag
        newid = "plantawatt:" + timeneeded + "000:plant" + timeneeded #This creates the new string for the id variable that sets the time to the current time
        id.text = newid #This changes the time to the current time
        root[4][6][0][0].text = PIN#This is where the PIN is changed to the correct PIN
        root[4][1].set('href', "/v1/User/{0}/Authorization/1".format(SAID)) #This sets one SAID to the correct SAID
        root[4][2].set('href', "/v1/User/{0}".format(SAID)) #This sets the other SAID to the correct SAID
        start_time = root[4][6][0][1][1]
        start_time.text = (str(int(time.time()-172800)))
        Authorization = root[4][6][0] #This pulls up the authorization tag. Again, this assumes that the authorization tag has a specific place.
        Authorization.set('xmlns', 'http://naesb.org/espi') #This sets the authorization tag to what it was orriginally. We are not really sure why we have to do this, but it works this way
        tree.write('testrequestsend.xml')#This writes our edited tree back into the testrequestsend.xml

        f = open('testrequestsend.xml', 'r')# this opens the file testrequestsend.xml
        XML = f.read()#This pulls the contents of the file into the XML file
        headers = { "Content-type": "text/html",   "Content-Length": "%d" % len(XML) }#This sets up the http headers. That the type is html and it tells PG&E the length of the file, the XML, that I am sending
        url = "https://partner.pge.com/GreenButtonWs/GreenButtonUsageService"#This targets the correct secure url to get into the PG&E
        opener = urllib.URLopener(key_file = 'myserver.key', cert_file = 'clientcertificate.pem')#defines opener as my credentials, the certificates
        conn = opener.open(url, XML)#This opens the conneciton to PG&E, specifying the XML file and the url
        outfile = open("/home/ubuntu/croncheck/PGEcroncheck"+str(datetime.datetime.today()),"w")#This sets the variable outfile to a file, with the filename containing the date, that is in a specific folder
        print conn.getcode()#This prints the http success code to the screen
        htmlreturn = conn.read()#This puts the PG&E html response in htmlreturn
        print htmlreturn #This prints htmlreturn out
        print >>outfile, conn.getcode(), htmlreturn#This puts both of those responses in the outfile
        if int(htmlreturn[8:11]) != 200 or int(conn.getcode()) != 200:
                try: #This is a try statement
                        conobjectmysql = mdb.connect(#password) #This creates a variable that has an interface to the database in it.
                        cursor = conobjectmysql.cursor() #This makes variable cursor equal to a cursor object, an object that holds the  querry results
                        cursor.execute('INSERT INTO Error_Table(HTTP_error_code, Notes, User_id, HTTP_tag) Values(%s, %s, %s, %s)', (conn.getcode(), "", Username, htmlreturn)); #This pulls up the SAID, PIN, Username from all users and places the results in cursor
                        conobjectmysql.commit()
                except mdb.Error, variable_for_saving_errors_in: #This puts in an exception if there is an error
                        print "Error {0}: {1}".format(*variable_for_saving_errors_in.args) #If there is an error, print the error
                        sys.exit(1) #Then exit out of this program (do not run the finally statement)
                finally: #And finally do the following
                        if conobjectmysql:
                                conobjectmysql.close() #Close the connection if it is still open

        conn.close()#This closes the connection to PG&E
        f.close()#This closes the testrequestsend.xml

try: #This is a try statement
        conobjectmysql = mdb.connect(#password) #This creates a variable that has an interface to the database in it.
        cursor = conobjectmysql.cursor() #This makes variable cursor equal to a cursor object, an object that holds the  querry results
        cursor.execute('SELECT SAID, PIN, Username FROM Users'); #This pulls up the SAID, PIN, Username from all users and places the results in cursor
        For_Iteration = cursor.fetchall() #Puts all the returned rows in For_Iteration
        for Each in For_Iteration: #Iterates this loop once for each row in For_Iteration, setting each to the row 
                SAID, PIN, Username = Each #Sets SAID, PIN, and Username to their respective values in the row
                xmleditorpge(PIN, SAID, Username) #This calls xmleditorpge to send a querry to get the user's (listed in that specific row) energy usage data
                time.sleep(.5)
except mdb.Error, variable_for_saving_errors_in: #This puts in an exception if there is an error
        print "Error {0}: {1}".format(*variable_for_saving_errors_in.args) #If there is an error, print the error
        sys.exit(1) #Then exit out of this program (do not run the finally statement)
finally: #And finally do the following
        if conobjectmysql:
                conobjectmysql.close() #Close the connection if it is still open
