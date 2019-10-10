<%@ Page Language="AVR" AutoEventWireup="false" CodeFile="StartPage.aspx.vr" Inherits="StartPage" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>Demo Get/POST</title>
</head>
<body>
    <h3>Demonstrate submitting GET and POST requests from AVR</h3>
    <form id="form1" runat="server">
    <div>
        Account Number (use 256 to get a declined transaction)<br />
        <asp:TextBox ID="textboxAccountNumber" value="144" runat="server"></asp:TextBox><br />
        Payment type<br />
        <asp:TextBox ID="textboxPaymentType" value="Credit" runat="server"></asp:TextBox><br />
        Transaction type<br />
        <asp:TextBox ID="textboxTransType" value="Sale" runat="server"></asp:TextBox><br />
        Amount<br />
        <asp:TextBox ID="textboxAmount" value="" runat="server"></asp:TextBox><br />
        
        <asp:Button ID="buttonSubmitPostRequest" runat="server" Text="Submit POST request" />
        <br />
        <asp:Button ID="buttonSubmitGetRequest" runat="server" Text="Submit GET request" />
        <br />
        <asp:Label ID="labelResponse" runat="server" Text=""></asp:Label>
    </div>
    </form>
</body>
</html>
