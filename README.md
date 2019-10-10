### How to submit GET and POST requests 

This example shows to submit GET and POST requests with the [System.Net.WebRequest](https://docs.microsoft.com/en-us/dotnet/api/system.net.webrequest?view=netframework-4.7.1) class. 

This example was originally created to as an example for making POST requests to a banking site (in that case the customer was using [Dejavoo Systems](http://www.dejavoosystems.com/)). Most financial authorization sites use very simple direct HTTP POST requests against an HTTP endpoint. This example focuses mostly on sending the request, but to ensure the submission is working a little proxy "service" is provided (the "TestTarget.aspx" page).

Figure 1 below shows the example's only visible page (StartPage.aspx). Most financial approvals require data submitted with an HTTP POST, but for completeness this examples show how to do both POST and GET requests. For very simple requests the GET method works fine. The difference in the two is the way data is passed to the target endpoint. POST requests send the request data within the request body; GET requests send the request data as a query string. While POST requests are sometimes considered more secure than GET requests, that's true only in the most naive sense. It is true that GET requests expose the data directly to eyeballs (in both the URL and secondary places like activity logs) and do enable the potential for cross-site forgery, but but otherwise POST data is as easily comprised as request data. A more critical difference between is either:

* Endpoint requirements. Dejavoo, and most other institutions, require POSTed data. However, if you're in charge of the endpoint, you can dictate either POST or GET. 
* Maximum data length. Query string maximum lengths vary by browser and Web server. 1024 characters is the generally accepted maximum (which includes keys and values). If you need to send more data than that it's probably best to use POST requests. 

StartPage.aspx

TestTarget.aspx 


![](https://asna.com/filebin/marketing/article-figures/demo-submit-request-response.png)

<small>Figure 1. The demo's only visible page.</small>

> There is an alternative way to submit HTTP requests using the [System.Net.Http.HttpClient](https://docs.microsoft.com/en-us/dotnet/api/system.net.http.httpclient?view=netframework-4.7.1) class. The method shown here, using the [System.Net.WebRequest](https://docs.microsoft.com/en-us/dotnet/api/system.net.webrequest?view=netframework-4.7.1) object works fine for synchronous requests. However, if you need asynchronous requests, consider using the HttpClient class.

