### How to submit GET and POST requests 

This example shows to submit GET and POST requests with the [System.Net.WebRequest](https://docs.microsoft.com/en-us/dotnet/api/system.net.webrequest?view=netframework-4.7.1) class. 

This example was originally created to as an example for making POST requests to a banking site (in that case the customer was using [Dejavoo Systems](http://www.dejavoosystems.com/)). Most financial authorization sites use very simple direct HTTP POST requests against an HTTP endpoint. This example focuses mostly on sending the request, but to ensure the submission is working a little proxy "service" is provided (the "TestTarget.aspx" page).

Figure 1 below shows the example's only visible page (StartPage.aspx). Most financial approvals require data submitted with an HTTP POST, but for completeness this examples show how to do both POST and GET requests. For very simple requests the GET method works fine. The difference in the two is the way data is passed to the target endpoint. POST requests send the request data within the request body; GET requests send the request data as a query string. 

While POST requests are sometimes considered more secure than GET requests, that's true only in the most naive sense. It is true that GET requests expose the data directly to eyeballs (in both the URL and secondary places like activity logs) and do enable the potential for cross-site forgery, but but otherwise POST data is as easily comprised as request data. More critical differences between the two are:

* **Endpoint requirements.** Dejavoo, and most other institutions, require POSTed data. However, if you're in charge of the endpoint, you can dictate either POST or GET. 
* **Maximum data length.** Query string maximum lengths aren't formally defined and vary by browser and Web server. 1024 characters is generally accepted as a safe maximum (which includes keys and values). If you need to send more data than that it's probably best to use POST requests. 

There are several other HTTP verbs (including DELETE, PUT, PATCH, etc). Using those verbs is beyond the context of this article. 

### The example's ASPX pages

This example has two Web pages

#### StartPage.aspx 

`StartPage.aspx's` logic performs POST or GET requests. It is shown below in Figure 1. 

![](https://asna.com/filebin/marketing/article-figures/demo-submit-request-response.png)

<small>Figure 1. The demo's only visible page.</small>

Inputs are provided for an account number, payment type, transaction type, and amount. There is minimal editing and error checking in this example it focuses on the mechanics of making HTTP POST and GET requests. 

After filling out the values, click one of the two buttons to make the corresponding HTTP request. 

After the HTTP request is made its response is shown under the buttons. Most of the responses the inputs to show that the input is making the round trip. The `TransactionStatus` and `RequestType` are additional values returned in the response. `TransactionStatus` shows either 'declined' or 'approved.' The simple logic used to calculate this is the account number. If it's 256 the transaction is declined otherwise it is accepted. In production, more complex and complete the logic would determine the transaction status. The `RequestType` echoes the HTTP verb used to make the request.

#### TestTarget.aspx 

`TestTarget.aspx` is the endpoint for the HTTP request. It provides the "service" for the HTTP request invoked by `StartPage.aspx`. There are better ways to provide a back-end Web service than using an ASPX page, but for very simple processes, especially those with minimal traffic, the ASPX works just fine. An ASPX page requires substantial workflow pipeline and for heavy duty service work consider using and HTTP handler or the [AVR Json Restful Controller](https://github.com/ASNA/avr-json-restful-controller). The latter option makes it especially easy to return Json data from the service. 

> As stated, the original purpose of this example was to test the Dejavoo service calls. As originally written, `TestTarget.aspx` was designed to be a stand-in for the Dejavoo service we needed. `TestTarget.aspx` originally echoed that service's logic and output. The absence of access to internals of third-party services make it challenging to effectively test your request logic. Stubbing `TestTarget.aspx` in as a stand-in gave a full request lifecycle test/debug experience and made it much easier to deploy the service with the confidence. While `TestTarget.aspx` has morphed a little in its transition from service proxy to example, it hasn't changed very much.

The `Page_Load` event hander is the service entry point and you'll notice that it starts with `Response.Clear()` and `Response.BufferOutput = *True` and ends with a `Response.Write()` and then a `Response.End()`. These chunks of code short-circuit the standard ASP.NET workflow pipeline and enables the page to render its direct HTTP response. It's this short circuit that keeps `TestTarget.aspx` from displaying--essentially making it a poor man's service. 

### The anatomy of `StartPage.aspx's` code behind

`StartPage.aspx.vr` has nine methods:

#### `InitiateSubmitPostRequest` and `InitiateSubmitGetRequest` 
These two methods collect input values as key/value pairs (in a `NameValueCollection` object) and then call the `SubmitRequest` routine to start the corresponding request process.

    BegSr InitiateSubmitPostRequest Access(*Private) + 
                                    Event(*This.buttonSubmitPostRequest.Click)
        DclSrParm sender Type(*Object)
        DclSrParm e Type(System.EventArgs)

        DclFld SubmitData Type(NameValueCollection) 
        DclFld DataReceived Type(NameValueCollection) 

        SubmitData = CollectSubmitData()

        // With POST verb, data is passed as an internal part of request content.
        DataReceived = SubmitRequest(HttpVerb.POST, 'TestTarget.aspx', SubmitData)
        ShowDataReceived(DataReceived) 
    EndSr
    
    BegSr InitiateSubmitGetRequest Access(*Private) +
                                   Event(*This.buttonSubmitGetRequest.Click)
        DclSrParm sender Type(*Object)
        DclSrParm e Type(System.EventArgs)

        DclFld SubmitData Type(NameValueCollection) 
        DclFld DataReceived Type(NameValueCollection) 

        SubmitData = CollectSubmitData()

        // With GET verb, data is passed as a query string.
        DataReceived = SubmitRequest(HttpVerb.GET, 'TestTarget.aspx', SubmitData)       
        ShowDataReceived(DataReceived) 
    EndSr

#### `SubmitRequest`

`SubmitRequest` calls `GetUrlWithPort` to ensure the dynamic port that IIS Express uses in Visual Studio is used in the URL. Then it encodes `SubmitData` (the key/value pairs of input data) with the `System.Web.HttpUtility.UrlEncode` method. Finally, it calls either `SubmitPostRequest` or `SubmitGetRequest` to perform the request. 

    BegFunc SubmitRequest Type(NameValueCollection) 
        DclSrParm RequestType Type(HttpVerb) 
        DclSrParm ASPXPage  Type(*String) 
        DclSrParm SubmitData Type(NameValueCollection) 

        DclFld url Type(*String) 
        DclFld encodedData Type(*String) 
        DclFld responseString Type(*String) 
        DclFld dataReceived Type(NameValueCollection) 

        url = GetUrlWithPort(ASPXPage) 
       
        // Convert your input values to a query string.
        encodedData = EncodeData(SubmitData)
        
        // responseString is the server response.
        If RequestType = HTTPVerb.POST
            responseString = SubmitPostRequest(url, encodedData)
        Else 
            responseString = SubmitGetRequest(url, encodedData)
        EndIF 
       
        // ParseQueryString transforms that query string value into
        // a name/value pair. This keeps you needing to parse 
        // that query string yourself. 
        LeaveSr HttpUtility.ParseQueryString(responseString) 
    EndFunc 

#### `SubmitPostRequest` and `SubmitGetRequest`

These two methods use the `System.Net.WebRequest` object to submit the corresponding synchronous request. The response is received as an instance of `System.Net.HttpWebResponse` and then converted to a string with the help of the `System.IO.StreamReader`. This string value is an ampersand-separated set of response value pairs (it looks like a query string) and it is returned to its caller. 

The two routines differ primarily in out request data is associated with the request. With the POST method, the value pair data is converted to an array of bytes and injected into the request body. With the GET method the value pair data is passed as as a query string. 

> There is an alternative way to submit HTTP requests using the [System.Net.Http.HttpClient](https://docs.microsoft.com/en-us/dotnet/api/system.net.http.httpclient?view=netframework-4.7.1) class. The technique shown here using the [System.Net.WebRequest](https://docs.microsoft.com/en-us/dotnet/api/system.net.webrequest?view=netframework-4.7.1) object works fine for synchronous requests. However, if you need asynchronous requests, consider using the `HttpClient` class.

#### `CollectSubmitData`

This method creates a `NameValueCollection` from input data to send along with the request. Add as many value pairs you need (with inputs collected from wherever they might be) to build the request data.

    BegFunc CollectSubmitData Type(NameValueCollection) 
        DclFld SubmitData Type(NameValueCollection) New()

        SubmitData.Add('AccountNumber', textboxAccountNumber.Text) 
        SubmitData.Add('PaymentType', textboxPaymentType.Text)
        SubmitData.Add('TransType', textboxTransType.Text)         
        SubmitData.Add('Amount', textboxAmount.Text) 

        LeaveSr SubmitData
    EndFunc 

#### `EncodeData` 

This method iterates the input data value pairs to encode each value. 

    BegFunc EncodeData Type(*String) 
        DclSrParm SubmitData Type(NameValueCollection) 
        
        DclFld Items Type(List(*Of *String)) New()
        
        ForEach Key Type(*String) Collection(SubmitData) 
            Items.Add(String.Format('{0}={1}', Key, System.Web.HttpUtility.UrlEncode(SubmitData[key])))
        EndFor
    
        LeaveSr String.Join('&', Items.ToArray())        
    EndFunc    

#### `GetUrlWithPort` 

This method builds the URL needed to make the request. This method is purely for development purposes and wouldn't be needed (most likely) for production purposes. 

    BegFunc GetUrlWithPort Type(*String) 
        DclSrParm ASPXPage Type(*String) 

        DclFld Port Type(*String) 

        Port = HttpContext.Current.Request.Url.Port
        LeaveSr String.Format('http://localhost:{0}/{1}', Port, ASPXPage)       
    EndFunc 

#### `ShowDataReceived` 

This method iterates over the response value pairs and builds a crude HTML string to display their values and values. 

    BegSr ShowDataReceived 
        DclSrParm DataReceived Type(NameValueCollection)

        DclFld Buffer Type(StringBuilder) New()        

        // ParseQueryString tranforms that query string value into
        // a name/value pair. This keeps you needing to parse that query string yourself. 
        buffer.Append('Data received from server:<br/>')
        
        ForEach Key Type(*String) Collection(DataReceived) 
            Buffer.Append(String.Format(' &bull; {0}={1}<br>', Key, DataReceived[key])) 
        EndFor 
       
        labelResponse.Text = Buffer.ToString()
    EndSr           

### The anatomy of `TestTarget.aspx's` code behind

`TestTarget.aspx.vr` has two methods:

#### `Page_Load` 

Remember that `TestTarget.aspx.vr` is a standard ASPX page. It's default behavior is governed by a built in HTTP handler for the ASPX page extension. This page acts as a very basic Web service so to short circuit the default ASPX page lifecycle, `Page_Load` starts with: 

        Response.Clear()     
        Response.BufferOutput = *True 

and ends with: 

        Response.Write(ResponseData)        
        Response.End() 

Otherwise, `Page_Load` does pretty simple work. It reads input values from the ASP.NET request object, encodes them, and returns them. It also has an `If` test to determine the `TransactionStatus` value.

#### EncodeData 

This is exactly the same `EncodeData` method that exists in `StartPage.aspx.vr`. By the time `TestTarget.aspx.vr's` `Page_Load` is called any encoded request data has been decoded implicitly by the ASP.NET pipeline. Therefore, it's necessary to encode the output data. 

This method is duplicated in both pages to keep the example simple. It production, it should probably be a shared member in a helper class. 

    BegFunc EncodeData Type(*String)
        DclSrParm SubmitData Type(NameValueCollection) 
        
        DclFld Items Type(List(*Of *String)) New()
        
        ForEach Key Type(*String) Collection(SubmitData) 
            Items.Add(String.Format('{0}={1}', key, System.Web.HttpUtility.UrlEncode(SubmitData[key])))
        EndFor
    
        LeaveSr String.Join('&', Items.ToArray())        
    EndFunc           
