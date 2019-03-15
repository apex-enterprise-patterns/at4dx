/**
 * Copyright (c) 2018, John M. Daniel
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *      this list of conditions and the following disclaimer in the documentation 
 *      and/or other materials provided with the distribution.
 * - Neither the name of the John M. Daniel, nor the names of its contributors 
 *      may be used to endorse or promote products derived from this software without 
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

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

            String bindingSObjectAPIName = null;

            list<ApplicationFactory_UnitOfWorkBinding__mdt> bindingRecords = [select DeveloperName, QualifiedAPIName, BindingSequence__c
                                                                                   , BindingSObject__c, BindingSObject__r.QualifiedApiName, BindingSObjectAlternate__c
                                                                                from ApplicationFactory_UnitOfWorkBinding__mdt
                                                                               order by BindingSequence__c];

            for ( ApplicationFactory_UnitOfWorkBinding__mdt bindingConfig : bindingRecords)
            {
                bindingSObjectAPIName = String.isNotBlank(bindingConfig.BindingSObject__c) ? bindingConfig.BindingSObject__r.QualifiedApiName : bindingConfig.BindingSObjectAlternate__c;

                if (String.isNotBlank(bindingSObjectAPIName)) 
                {
                    sobjDescribe = Schema.describeSObjects(new String[] { bindingSObjectAPIName.toLowerCase().trim() });

                    if(sobjDescribe.size() != 1) 
                    {
                        throw new di_Injector.InjectorException('Failed to find SObject ' + bindingSObjectAPIName 
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
