/**
 *
 * di_Module based class used to manage the Application Factory mappings of for the SOBject
 */
public class ApplicationSObjectUnitOfWorkDIModule 
    extends di_Module
{
    // TODO: Finish the implementation of this method
    public override void configure() 
    {
        System.debug('loading the SObjectUnitOfWork bindings for Application Factory');
        Schema.DescribeSobjectResult[] results = null;

        for ( ApplicationFactory_UnitOfWorkBinding__mdt bindingConfig : [select DeveloperName, QualifiedAPIName, BindingSequence__c, BindingSObject__c 
                                                                         from ApplicationFactory_UnitOfWorkBinding__mdt])
        {
            apex();
            if (String.isNotBlank(bindingConfig.BindingSObject__c)) 
            {
                results = Schema.describeSObjects(new String[] { bindingConfig.BindingSObject__c.toLowerCase().trim() });
                if(results.size() != 1) 
                {
                    throw new di_Injector.InjectorException('Failed to find SObject ' + bindingConfig.BindingSObject__c + ' referened by binding ' + bindingConfig.DeveloperName + ' for ApplicationSObjectUnitOfWorkDIModule di_Injectory module.');
                }
                bind(results[0].getSObjectType());
                bind(IApplicationSObjectUnitOfWork.class);
            }
            data(bindingConfig);
            if(bindingConfig.BindingSequence__c != null) {
                sequence(Integer.valueOf(bindingConfig.BindingSequence__c));
            }
            //to(bindingConfig.To__c);
        }
    }
}
