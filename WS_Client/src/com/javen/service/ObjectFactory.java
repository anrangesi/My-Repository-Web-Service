
package com.javen.service;

import javax.xml.bind.JAXBElement;
import javax.xml.bind.annotation.XmlElementDecl;
import javax.xml.bind.annotation.XmlRegistry;
import javax.xml.namespace.QName;


/**
 * This object contains factory methods for each 
 * Java content interface and Java element interface 
 * generated in the com.javen.service package. 
 * <p>An ObjectFactory allows you to programatically 
 * construct new instances of the Java representation 
 * for XML content. The Java representation of XML 
 * content can consist of schema derived interfaces 
 * and classes representing the binding of schema 
 * type definitions, element declarations and model 
 * groups.  Factory methods for each of these are 
 * provided in this class.
 * 
 */
@XmlRegistry
public class ObjectFactory {

    private final static QName _DeleteByIdResponse_QNAME = new QName("http://service.javen.com/", "deleteByIdResponse");
    private final static QName _SelectById_QNAME = new QName("http://service.javen.com/", "selectById");
    private final static QName _UpdateById_QNAME = new QName("http://service.javen.com/", "updateById");
    private final static QName _SelectAll_QNAME = new QName("http://service.javen.com/", "selectAll");
    private final static QName _SelectAllResponse_QNAME = new QName("http://service.javen.com/", "selectAllResponse");
    private final static QName _SelectNameLogin_QNAME = new QName("http://service.javen.com/", "selectNameLogin");
    private final static QName _DeleteById_QNAME = new QName("http://service.javen.com/", "deleteById");
    private final static QName _UpdateByIdResponse_QNAME = new QName("http://service.javen.com/", "updateByIdResponse");
    private final static QName _SelectByIdResponse_QNAME = new QName("http://service.javen.com/", "selectByIdResponse");
    private final static QName _SelectLogin_QNAME = new QName("http://service.javen.com/", "selectLogin");
    private final static QName _SelectNameLoginResponse_QNAME = new QName("http://service.javen.com/", "selectNameLoginResponse");
    private final static QName _SelectLoginResponse_QNAME = new QName("http://service.javen.com/", "selectLoginResponse");

    /**
     * Create a new ObjectFactory that can be used to create new instances of schema derived classes for package: com.javen.service
     * 
     */
    public ObjectFactory() {
    }

    /**
     * Create an instance of {@link SelectLogin }
     * 
     */
    public SelectLogin createSelectLogin() {
        return new SelectLogin();
    }

    /**
     * Create an instance of {@link SelectLogin.Arg0 }
     * 
     */
    public SelectLogin.Arg0 createSelectLoginArg0() {
        return new SelectLogin.Arg0();
    }

    /**
     * Create an instance of {@link SelectByIdResponse }
     * 
     */
    public SelectByIdResponse createSelectByIdResponse() {
        return new SelectByIdResponse();
    }

    /**
     * Create an instance of {@link UpdateByIdResponse }
     * 
     */
    public UpdateByIdResponse createUpdateByIdResponse() {
        return new UpdateByIdResponse();
    }

    /**
     * Create an instance of {@link DeleteById }
     * 
     */
    public DeleteById createDeleteById() {
        return new DeleteById();
    }

    /**
     * Create an instance of {@link SelectLoginResponse }
     * 
     */
    public SelectLoginResponse createSelectLoginResponse() {
        return new SelectLoginResponse();
    }

    /**
     * Create an instance of {@link SelectNameLoginResponse }
     * 
     */
    public SelectNameLoginResponse createSelectNameLoginResponse() {
        return new SelectNameLoginResponse();
    }

    /**
     * Create an instance of {@link SelectById }
     * 
     */
    public SelectById createSelectById() {
        return new SelectById();
    }

    /**
     * Create an instance of {@link DeleteByIdResponse }
     * 
     */
    public DeleteByIdResponse createDeleteByIdResponse() {
        return new DeleteByIdResponse();
    }

    /**
     * Create an instance of {@link SelectNameLogin }
     * 
     */
    public SelectNameLogin createSelectNameLogin() {
        return new SelectNameLogin();
    }

    /**
     * Create an instance of {@link SelectAllResponse }
     * 
     */
    public SelectAllResponse createSelectAllResponse() {
        return new SelectAllResponse();
    }

    /**
     * Create an instance of {@link SelectAll }
     * 
     */
    public SelectAll createSelectAll() {
        return new SelectAll();
    }

    /**
     * Create an instance of {@link UpdateById }
     * 
     */
    public UpdateById createUpdateById() {
        return new UpdateById();
    }

    /**
     * Create an instance of {@link User }
     * 
     */
    public User createUser() {
        return new User();
    }

    /**
     * Create an instance of {@link SelectLogin.Arg0 .Entry }
     * 
     */
    public SelectLogin.Arg0 .Entry createSelectLoginArg0Entry() {
        return new SelectLogin.Arg0 .Entry();
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link DeleteByIdResponse }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://service.javen.com/", name = "deleteByIdResponse")
    public JAXBElement<DeleteByIdResponse> createDeleteByIdResponse(DeleteByIdResponse value) {
        return new JAXBElement<DeleteByIdResponse>(_DeleteByIdResponse_QNAME, DeleteByIdResponse.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link SelectById }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://service.javen.com/", name = "selectById")
    public JAXBElement<SelectById> createSelectById(SelectById value) {
        return new JAXBElement<SelectById>(_SelectById_QNAME, SelectById.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link UpdateById }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://service.javen.com/", name = "updateById")
    public JAXBElement<UpdateById> createUpdateById(UpdateById value) {
        return new JAXBElement<UpdateById>(_UpdateById_QNAME, UpdateById.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link SelectAll }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://service.javen.com/", name = "selectAll")
    public JAXBElement<SelectAll> createSelectAll(SelectAll value) {
        return new JAXBElement<SelectAll>(_SelectAll_QNAME, SelectAll.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link SelectAllResponse }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://service.javen.com/", name = "selectAllResponse")
    public JAXBElement<SelectAllResponse> createSelectAllResponse(SelectAllResponse value) {
        return new JAXBElement<SelectAllResponse>(_SelectAllResponse_QNAME, SelectAllResponse.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link SelectNameLogin }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://service.javen.com/", name = "selectNameLogin")
    public JAXBElement<SelectNameLogin> createSelectNameLogin(SelectNameLogin value) {
        return new JAXBElement<SelectNameLogin>(_SelectNameLogin_QNAME, SelectNameLogin.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link DeleteById }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://service.javen.com/", name = "deleteById")
    public JAXBElement<DeleteById> createDeleteById(DeleteById value) {
        return new JAXBElement<DeleteById>(_DeleteById_QNAME, DeleteById.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link UpdateByIdResponse }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://service.javen.com/", name = "updateByIdResponse")
    public JAXBElement<UpdateByIdResponse> createUpdateByIdResponse(UpdateByIdResponse value) {
        return new JAXBElement<UpdateByIdResponse>(_UpdateByIdResponse_QNAME, UpdateByIdResponse.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link SelectByIdResponse }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://service.javen.com/", name = "selectByIdResponse")
    public JAXBElement<SelectByIdResponse> createSelectByIdResponse(SelectByIdResponse value) {
        return new JAXBElement<SelectByIdResponse>(_SelectByIdResponse_QNAME, SelectByIdResponse.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link SelectLogin }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://service.javen.com/", name = "selectLogin")
    public JAXBElement<SelectLogin> createSelectLogin(SelectLogin value) {
        return new JAXBElement<SelectLogin>(_SelectLogin_QNAME, SelectLogin.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link SelectNameLoginResponse }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://service.javen.com/", name = "selectNameLoginResponse")
    public JAXBElement<SelectNameLoginResponse> createSelectNameLoginResponse(SelectNameLoginResponse value) {
        return new JAXBElement<SelectNameLoginResponse>(_SelectNameLoginResponse_QNAME, SelectNameLoginResponse.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link SelectLoginResponse }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://service.javen.com/", name = "selectLoginResponse")
    public JAXBElement<SelectLoginResponse> createSelectLoginResponse(SelectLoginResponse value) {
        return new JAXBElement<SelectLoginResponse>(_SelectLoginResponse_QNAME, SelectLoginResponse.class, null, value);
    }

}
