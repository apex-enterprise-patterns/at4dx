/**
 *
 * di_Module based class used to manage the Application Factory mappings of for the SOBject
 */
public class ApplicationSObjectDomainDIModule 
    extends di_Module
{
    public override void configure() 
    {
        System.debug('loading the SObjectDomain bindings for Application Factory');
        Schema.DescribeSobjectResult[] results = null;

        for ( ApplicationFactory_DomainBinding__mdt bindingConfig : [select DeveloperName, QualifiedAPIName, To__c, BindingSObject__c 
                                                                         from ApplicationFactory_DomainBinding__mdt])
        {
            apex();
            if (String.isNotBlank(bindingConfig.BindingSObject__c)) 
            {
                results = Schema.describeSObjects(new String[] { bindingConfig.BindingSObject__c.toLowerCase().trim() });
                if(results.size() != 1) 
                {
                    throw new di_Injector.InjectorException('Failed to find SObject ' + bindingConfig.BindingSObject__c + ' referened by binding ' + bindingConfig.DeveloperName + ' for ApplicationSObjectDomainDIModule di_Injectory module.');
                }
                bind(results[0].getSObjectType());
                bind(IApplicationSObjectDomain.class);
            }
            data(bindingConfig);
            to(bindingConfig.To__c);
        }
    }
}
