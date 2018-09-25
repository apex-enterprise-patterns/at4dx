public class ApplicationSObjectUnitOfWorkDIProvider 
    implements di_Binding.Provider
{
    private fflib_SObjectUnitOfWork.IDML dmlParam = null;
    private List<Schema.SObjectType> sObjTypesParam = null;

    private void parseParamType(Object param)
    {
        if ( param != null )
        {
            if ( param instanceOf fflib_SObjectUnitOfWork.IDML )
            {
                this.dmlParam = (fflib_SObjectUnitOfWork.IDML)param;
            }
            else if ( param instanceOf List<Schema.SObjectType> )
            {
                this.sObjTypesParam = (List<Schema.SObjectType>)param;
            }
            else 
            {
                throw new di_Injector.InjectorException('Failed to determine instance type of params passed to ' + this + '.  Params argument supplied is --- ' + param);
            }
        }
    }

    private void parseParams(Object params)
    {
        if ( params instanceOf List<SObjectType> )
        {
            parseParamType(params);
        }
        else if ( params instanceOf List<Object> )
        {
            for ( Object param : (List<Object>)params)
            {
                parseParamType(param);
            }
        }
        else 
        {
            parseParamType(params);
        }
    }

    public Object newInstance(Object params)
    {
        IApplicationSObjectUnitOfWork uow = null;

        parseParams(params);

        // if the SObjectTypes were not passed in via the params method...
        if ( this.sObjTypesParam == null )
        {
            // then query default ApplicationFactory_UnitOfWorkBinding__mdt records
            this.sObjTypesParam = new List<Schema.SObjectType>();
            Schema.DescribeSobjectResult[] sobjDescribe = null;

            for ( ApplicationFactory_UnitOfWorkBinding__mdt bindingConfig : [select DeveloperName, QualifiedAPIName, BindingSequence__c
                                                                                  , BindingSObject__c, BindingSObject__r.QualifiedApiName
                                                                               from ApplicationFactory_UnitOfWorkBinding__mdt
                                                                              order by BindingSequence__c])
            {
                if (String.isNotBlank(bindingConfig.BindingSObject__c)) 
                {
                    sobjDescribe = Schema.describeSObjects(new String[] { bindingConfig.BindingSObject__r.QualifiedApiName.toLowerCase().trim() });

                    if(sobjDescribe.size() != 1) 
                    {
                        throw new di_Injector.InjectorException('Failed to find SObject ' + bindingConfig.BindingSObject__r.QualifiedApiName 
                                                                     + ' referened by binding ' + bindingConfig.DeveloperName 
                                                                     + ' for ApplicationSObjectUnitOfWorkDIModule di_Injectory module.');
                    }
                    this.sObjTypesParam.add( sobjDescribe[0].getSObjectType() );
                }
            }
        }

        if ( this.dmlParam != null )
        {
            uow = new ApplicationSObjectUnitOfWork( this.sObjTypesParam, this.dmlParam );
        }
        else 
        {
            uow = new ApplicationSObjectUnitOfWork( this.sObjTypesParam );
        }
        
        return uow;
    }
}
