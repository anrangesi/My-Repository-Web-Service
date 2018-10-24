
package com.javen.service;

import java.net.MalformedURLException;
import java.net.URL;
import javax.xml.namespace.QName;
import javax.xml.ws.Service;
import javax.xml.ws.WebEndpoint;
import javax.xml.ws.WebServiceClient;
import javax.xml.ws.WebServiceException;
import javax.xml.ws.WebServiceFeature;


/**
 * This class was generated by the JAX-WS RI.
 * JAX-WS RI 2.2.4-b01
 * Generated source version: 2.2
 * 
 */
@WebServiceClient(name = "UserServiceImplService", targetNamespace = "http://impl.service.javen.com/", wsdlLocation = "http://localhost:8091/WS_WebService/server/web-publish?wsdl")
public class UserServiceImplService
    extends Service
{

    private final static URL USERSERVICEIMPLSERVICE_WSDL_LOCATION;
    private final static WebServiceException USERSERVICEIMPLSERVICE_EXCEPTION;
    private final static QName USERSERVICEIMPLSERVICE_QNAME = new QName("http://impl.service.javen.com/", "UserServiceImplService");

    static {
        URL url = null;
        WebServiceException e = null;
        try {
            url = new URL("http://localhost:8091/WS_WebService/server/web-publish?wsdl");
        } catch (MalformedURLException ex) {
            e = new WebServiceException(ex);
        }
        USERSERVICEIMPLSERVICE_WSDL_LOCATION = url;
        USERSERVICEIMPLSERVICE_EXCEPTION = e;
    }

    public UserServiceImplService() {
        super(__getWsdlLocation(), USERSERVICEIMPLSERVICE_QNAME);
    }

    public UserServiceImplService(WebServiceFeature... features) {
        super(__getWsdlLocation(), USERSERVICEIMPLSERVICE_QNAME, features);
    }

    public UserServiceImplService(URL wsdlLocation) {
        super(wsdlLocation, USERSERVICEIMPLSERVICE_QNAME);
    }

    public UserServiceImplService(URL wsdlLocation, WebServiceFeature... features) {
        super(wsdlLocation, USERSERVICEIMPLSERVICE_QNAME, features);
    }

    public UserServiceImplService(URL wsdlLocation, QName serviceName) {
        super(wsdlLocation, serviceName);
    }

    public UserServiceImplService(URL wsdlLocation, QName serviceName, WebServiceFeature... features) {
        super(wsdlLocation, serviceName, features);
    }

    /**
     * 
     * @return
     *     returns IUserService
     */
    @WebEndpoint(name = "UserServiceImplPort")
    public IUserService getUserServiceImplPort() {
        return super.getPort(new QName("http://impl.service.javen.com/", "UserServiceImplPort"), IUserService.class);
    }

    /**
     * 
     * @param features
     *     A list of {@link javax.xml.ws.WebServiceFeature} to configure on the proxy.  Supported features not in the <code>features</code> parameter will have their default values.
     * @return
     *     returns IUserService
     */
    @WebEndpoint(name = "UserServiceImplPort")
    public IUserService getUserServiceImplPort(WebServiceFeature... features) {
        return super.getPort(new QName("http://impl.service.javen.com/", "UserServiceImplPort"), IUserService.class, features);
    }

    private static URL __getWsdlLocation() {
        if (USERSERVICEIMPLSERVICE_EXCEPTION!= null) {
            throw USERSERVICEIMPLSERVICE_EXCEPTION;
        }
        return USERSERVICEIMPLSERVICE_WSDL_LOCATION;
    }

}
