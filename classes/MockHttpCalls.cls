/**
 * @description       : HttpCalloutMock interface to specify the response sent in the respond method, which the Apex runtime calls to send a response for a callout
 * @author            : marcos.gimeno@vass.es
 * @group             : VASS
 * @last modified on  : 06-21-2022
 * @last modified by  : Rafael Vargas Pinilla
**/
@isTest
public class MockHttpCalls implements HttpCalloutMock {

    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;

    @SuppressWarnings('PMD.ExcessiveParameterList')
    public MockHttpCalls(Integer code, String status, String body, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.body = body;
        this.responseHeaders = responseHeaders;
    }

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        for (String key : this.responseHeaders.keySet()) {
            res.setHeader(key, this.responseHeaders.get(key));
        }

        if(String.isNotBlank(this.body)) res.setBody(this.body);
        
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        return res;
    }
}