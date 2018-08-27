/**
 *
 * di_Module based class used to manage the Application Factory mappings of for services
 */
public class ApplicationSObjectServiceDIModule 
    extends di_Module
{
    public override void configure() 
    {
        System.debug('loading the Service bindings for Application Factory');

        Type interfaceType = null;

        for ( ApplicationFactory_ServiceBinding__mdt bindingConfig : [select DeveloperName, QualifiedAPIName, To__c, BindingInterface__c 
                                                                         from ApplicationFactory_ServiceBinding__mdt])
        {
            apex();
            try {
                Type.forName(bindingConfig.BindingInterface__c);
            } catch (TypeException te) {
                throw new di_Injector.InjectorException('Service Interface ' + bindingConfig.BindingInterface__c + ' referened by binding ' + bindingConfig.DeveloperName + ' does not exist.');
            }
            bind(bindingConfig.BindingInterface__c);
            data(bindingConfig);
            to(bindingConfig.To__c);
        }
    }
}
