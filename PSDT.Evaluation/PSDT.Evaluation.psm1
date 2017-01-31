Function Execute-SOAPRequest {
    <#
        .Synopsis
            The function executes a SOAP request and returns the response XML.
        .Example
            $soap = [xml]@'
            <?xml version="1.0" encoding="utf-8"?>
            <soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">
                <soap12:Body>
                <Valid8Address xmlns="http://www.facilities.co.za/valid8service/valid8service">
                    <ID>string</ID>
                    <Address1></Address1>
                    <Address2></Address2>
                    <Address3></Address3>
                    <Address4></Address4>
                    <Address5></Address5>
                    <Address6></Address6>
                    <PostCode></PostCode>
                </Valid8Address>
                </soap12:Body>
            </soap12:Envelope>
            '@;

            Execute-SOAPRequest -SOAPRequest $soap -URL "http://www.facilities.co.za/valid8service/valid8service.asmx" -SOAPAction "`"http://www.facilities.co.za/valid8service/valid8service/Valid8Address`"";

            The above script declares the $soap variable and sets a valid xml as value. The Execute-SOAPRequest cmdlet sends the SOAP request (-SOAPRequest $soap) to a specific url (-URL ..).
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True)]
        [String]$URL,
        [Parameter(Mandatory=$True)]
        [String]$SOAPAction,
        [Parameter(Mandatory=$True)]
        [Xml]$SOAPRequest
    )

    Write-Verbose "Sending SOAP request to server: $URL" 
    $soapWebRequest = [System.Net.WebRequest]::Create($URL) 
    $soapWebRequest.Headers.Add("SOAPAction", $SOAPAction)

    $soapWebRequest.ContentType = "text/xml;charset=`"utf-8`"" 
    $soapWebRequest.Accept      = "text/xml" 
    $soapWebRequest.Method      = "POST" 
        
    Write-Verbose "Initiating send." 
    $requestStream = $soapWebRequest.GetRequestStream() 
    $SOAPRequest.Save($requestStream) 
    $requestStream.Close() 
        
    Write-Verbose "Send Complete, Waiting For Response." 
    $resp = $soapWebRequest.GetResponse() 
    $responseStream = $resp.GetResponseStream() 
    $soapReader = [System.IO.StreamReader]($responseStream) 
    $ReturnXml = [Xml] $soapReader.ReadToEnd() 
    $responseStream.Close() 
        
    Write-Verbose "Response received."

    return $ReturnXml 
}