<%@ Language=VBScript %>
<%
   Dim sRTF, sConn
   sConn = "c:\program files\microsoft office\office\samples\northwind.mdb"

   Response.Buffer = True

   'Create the file for the RTF
   Dim fso, MyFile, sFileName
   Set fso = CreateObject("Scripting.FileSystemObject")
   sFileName = "sample2.doc"
   Set MyFile = fso.CreateTextFile(Server.MapPath(".") & "\" & _
                                   sFileName, True)

   MyFile.WriteLine("{\rtf1")

   'Write the font table
   sRTF = "{\fonttbl {\f0\froman\fcharset0 Times New Roman;}" & _
          "{\f1\fswiss\fcharset0 Arial;}" & _
          "{\f2\fmodern\fcharset0 Courier New;}}"
   MyFile.WriteLine sRTF

   'Write the title and author for the document properties
   MyFile.WriteLine("{\info{\title Sample RTF Document}" & _
                    "{\author Microsoft Developer Support}}")

   'Write the document header and footer
   MyFile.WriteLine("{\header\pard\qc\brdrb\brdrs\brdrw10\brsp100" & _
                    "{\fs50 Northwind Traders} \par}")
   MyFile.WriteLine("{\footer\pard\qc\brdrt\brdrs\brdrw10\brsp100" & _
                    "{\fs18 Questions?\par Call (111)-222-3333, " & _
                    " Monday-Friday between 8:00 am and 5:00 pm} \par}")

   'Connect to the database in read-only mode
   Dim conn, rs
   Set conn = Server.CreateObject("ADODB.Connection")
   conn.Provider = "Microsoft.Jet.OLEDB.4.0"
   conn.Mode = 1    'adModeRead=1
   conn.Open sConn

   'Execute a query that returns ID, Product name and amount of sale
   Set rs = Server.CreateObject("ADODB.Recordset")
   rs.Open "SELECT Orders.ShippedDate, Orders.ShipVia, " & _
           "Orders.OrderDate, Orders.OrderID, " & _
           "Customers.ContactName FROM Customers INNER JOIN Orders ON " & _
           "Customers.CustomerID = " & _
           "Orders.CustomerID WHERE (((Orders.ShippedDate) Between " & _
           "#1/1/1998# And #3/31/98#))",conn,3  'adOpenStatic = 3

   Do While Not (rs.eof)
     
     'Write the "body" of the form letter
    
     MyFile.WriteLine   "\fs26\f1"   'Default font

     MyFile.WriteLine   "\pard"
     MyFile.WriteLine   "\par\par\par\par"
     MyFile.WriteLine   "\par RE: Order #" & rs.Fields("OrderID").Value
     MyFile.WriteLine   "\par"
     MyFile.WriteLine   "\par"
     MyFile.WriteLine   "\par " & rs.Fields("ContactName").Value & ", "
     MyFile.WriteLine   "\par"
     MyFile.WriteLine   "\par Thank you for your order on " & _
                        rs.Fields("ShippedDate").Value & _
                        ". Your order has been shipped: "
     MyFile.WriteLine   "\par"
     MyFile.WriteLine   "\par"

     MyFile.WriteLine   "\pard \li720 {\f2"
     MyFile.WriteLine   "\par \b Order Number \b0 \tab " & _
                        rs.Fields("OrderID").Value
     MyFile.WriteLine   "\par \b Shipped By \b0 \tab " & _
                        rs.Fields("ShipVia").Value
     MyFile.WriteLine   "\par \b Shipped On \b0 \tab " & _
                        rs.Fields("ShippedDate").Value
     MyFile.WriteLine   "\par}"
    
     MyFile.WriteLine   "\pard"
     MyFile.WriteLine   "\par"
     MyFile.WriteLine   "\par Northwind Traders is committed to " & _
                        "bringing you products of the " & _
                        "highest quality from all over the world. If " & _
                        "at any time you are not completely satisfied " & _
                        "with any of our products, you may " & _
                        "return them to us for a full refund."
     MyFile.WriteLine   "\par"

     MyFile.WriteLine   "\pard {\fs18 \qc \i"
     MyFile.WriteLine   "\par Thank you for choosing Northwind Traders!"
     MyFile.WriteLine   "\par}"

     rs.MoveNext

     'Add a page break and then a new paragraph
     If Not(rs.eof) Then MyFile.WriteLine("\pard \page")

   Loop

   'Close the recordset and database
   rs.Close
   conn.Close
   Set rs = Nothing
   Set conn = Nothing
   
   'close the RTF string and file
   MyFile.WriteLine("}")
   MyFile.Close

   Response.Write _
        "<META HTTP-EQUIV=""REFRESH"" Content=""0;URL=" & sFileName & """>"

%> 