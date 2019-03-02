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

public class DomainProcessCoordinator 
    implements IDomainProcessCoordinator, di_Binding.Provider
{
    private IApplicationSObjectDomain sObjectDomain = null;

    // The domainProcessMap organizes all of the domain process custom metadata record entries
    // The map is organized by ProcessContext__c, DomainMethodToken__c/TriggerOperation__c, "Sequence" (infered from the OrderOfExecution__c), Type__c, OrderOfExecution__c, --- DomainProcessBinding__mdt record which contains the ClassToInject__c
    private Map<DomainProcessConstants.PROCESS_CONTEXT, Map<String, Map<Integer, Map<DomainProcessConstants.PROCESS_TYPE, Map<Decimal, DomainProcessBinding__mdt>>>>> domainProcessMap = new Map<DomainProcessConstants.PROCESS_CONTEXT, Map<String, Map<Integer, Map<DomainProcessConstants.PROCESS_TYPE, Map<Decimal, DomainProcessBinding__mdt>>>>>();

    private Map<DomainProcessConstants.PROCESS_CONTEXT, Map<String, Map<Integer, Map<DomainProcessConstants.PROCESS_TYPE, Map<Decimal, DomainProcessBinding__mdt>>>>> getDomainProcessMap()
    {
        //system.debug( 'getDomainProcessMap() called');
        if ( this.domainProcessMap.isEmpty() )
        {
            // system.debug( 'domainProcessMap found to be empty.  Now prime the relevant Domain Logic Injections records');
            primeDomainLogicInjections();
        }
        return this.domainProcessMap;
    }

    @TestVisible
    private list<DomainProcessBinding__mdt> mockDomainProcesses = new list<DomainProcessBinding__mdt>();

    private void primeDomainLogicInjections()
    {
        // TODO: this should be moved to Force-DI

        String sobjAPIName = this.sObjectDomain.getSObjectDescribe().getName();

        // find all process DomainProcessBinding__mdt records that are related
        // Unfortuantely, you cannot query MDTs with a where clause of "this or that".  If you do, it throws a "Disjunctions not supported" exception
        // So, you have to query the records with two queries and add them together.
        // first query the RelatedDomainBindingSObject__r.QualifiedApiName = :sobjAPIName
        list<DomainProcessBinding__mdt> domainProcesses = [select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName
                                                         , ClassToInject__c, Description__c, DomainMethodToken__c, ExecuteAsynchronous__c, IsActive__c
                                                         , LogicalInverse__c, OrderOfExecution__c, PreventRecursive__c, ProcessContext__c
                                                         , RelatedDomainBindingSObject__c, RelatedDomainBindingSObject__r.QualifiedApiName, RelatedDomainBindingSObjectAlternate__c
                                                         , TriggerOperation__c, Type__c
                                                      from DomainProcessBinding__mdt
                                                     where RelatedDomainBindingSObject__r.QualifiedApiName = :sobjAPIName
                                                       and IsActive__c = true
                                                     order by ProcessContext__c, TriggerOperation__c, OrderOfExecution__c, Type__c];
        // second, query RelatedDomainBindingSObjectAlternate__c = :sobjAPIName
        domainProcesses.addAll([select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName
                                                         , ClassToInject__c, Description__c, DomainMethodToken__c, ExecuteAsynchronous__c, IsActive__c
                                                         , LogicalInverse__c, OrderOfExecution__c, PreventRecursive__c, ProcessContext__c
                                                         , RelatedDomainBindingSObject__c, RelatedDomainBindingSObject__r.QualifiedApiName, RelatedDomainBindingSObjectAlternate__c
                                                         , TriggerOperation__c, Type__c
                                                      from DomainProcessBinding__mdt
                                                     where RelatedDomainBindingSObjectAlternate__c = :sobjAPIName
                                                       and IsActive__c = true
                                                     order by ProcessContext__c, TriggerOperation__c, OrderOfExecution__c, Type__c]);

        //if (System.Test.isRunningTest() && mockDomainProcesses != null)
        //system.debug( 'this.mockDomainProcesses == ' + this.mockDomainProcesses );

        // TODO : Figure out how mock domain processes should be handled
        if ( ! this.mockDomainProcesses.isEmpty() )
        {
            domainProcesses.clear();
            domainProcesses.addAll( mockDomainProcesses );
            //system.debug( 'this.mockDomainProcesses == ' + this.mockDomainProcesses );
        }

        DomainProcessConstants.PROCESS_CONTEXT processContext = null;
        String domainProcessToken = null;
        Integer sequence = null;
        DomainProcessConstants.PROCESS_TYPE processType = null;

        // need to sort these domainProcesses by ProcessContext__c, DomainMethodToken__c/TriggerOperation__c, "Sequence" (infered from the OrderOfExecution__c), Type__c, OrderOfExecution__c, --- ClassToInject__c
        //                                    map< string,          map< string,                              map< integer,                                      map< string, map< decimal, String> > > > >
        for ( DomainProcessBinding__mdt domainProcess : domainProcesses )
        {
            processContext = DomainProcessConstants.PROCESS_CONTEXT.TriggerExecution.name().equalsIgnoreCase( domainProcess.ProcessContext__c ) ? DomainProcessConstants.PROCESS_CONTEXT.TriggerExecution : DomainProcessConstants.PROCESS_CONTEXT.DomainMethodExecution;

            if ( ! domainProcessMap.containsKey( processContext ) )
            {
                domainProcessMap.put( processContext, new Map<String, Map<Integer, Map<DomainProcessConstants.PROCESS_TYPE, Map<Decimal, DomainProcessBinding__mdt>>>>() );
            }

            domainProcessToken = ( string.isBlank( domainProcess.DomainMethodToken__c ) ? domainProcess.TriggerOperation__c : domainProcess.DomainMethodToken__c ).toLowerCase();

            if ( ! domainProcessMap.get( processContext ).containsKey( domainProcessToken ) )
            {
                domainProcessMap.get( processContext ).put( domainProcessToken, new Map<Integer, Map<DomainProcessConstants.PROCESS_TYPE, Map<Decimal, DomainProcessBinding__mdt>>>() );
            }

            sequence = Integer.valueOf( domainProcess.OrderOfExecution__c );

            if ( ! domainProcessMap.get( processContext ).get( domainProcessToken ).containsKey( sequence ) )
            {
                domainProcessMap.get( processContext ).get( domainProcessToken ).put( sequence, new Map<DomainProcessConstants.PROCESS_TYPE, Map<Decimal, DomainProcessBinding__mdt>>() );
            }

            processType = DomainProcessConstants.PROCESS_TYPE.CRITERIA.name().equalsIgnoreCase( domainProcess.Type__c ) ? DomainProcessConstants.PROCESS_TYPE.CRITERIA : DomainProcessConstants.PROCESS_TYPE.ACTION;

            if ( ! domainProcessMap.get( processContext ).get( domainProcessToken ).get( sequence ).containsKey( processType ) )
            {
                domainProcessMap.get( processContext ).get( domainProcessToken ).get( sequence ).put( processType, new Map<Decimal, DomainProcessBinding__mdt>() );
            }

            domainProcessMap.get( processContext ).get( domainProcessToken ).get( sequence ).get( processType ).put( domainProcess.OrderOfExecution__c, domainProcess );
        }
    }

    public DomainProcessCoordinator()
    {
        
    }

    public DomainProcessCoordinator(IApplicationSObjectDomain sObjectDomain)
    {
        if (sObjectDomain == null)
        {
            throw new DomainProcessCoordinator.ProcessInjectionException('The DomainProcessCoordinator must be used in conjunction with a IApplicationSObjectDomain as a constructor parameter.');
        }
        this.sObjectDomain = sObjectDomain;
    }

    public Object newInstance(Object params)
    {
        if ( params == null )
        {
            throw new di_Binding.BindingException('No params object supplied');
        }

        if ( ! (params instanceOf IApplicationSObjectDomain ) )
        {
            throw new di_Binding.BindingException('The params object must implement IApplicationSObjectDomain');
        }

        return new DomainProcessCoordinator( (IApplicationSObjectDomain)params );
    }

    /**
    *  Call this method either from a domain class method or it is automatically called from trigger context
    *  and any criteria and actions for that combination will be executed.
    */
    public void processDomainLogicInjections(String domainProcessToken )
    {
        processDomainLogicInjections( DomainProcessConstants.PROCESS_CONTEXT.DomainMethodExecution, domainProcessToken, null, null );
    }

    /**
    *  Call this method either from a domain class method or it is automatically called from trigger context
    *  and any criteria and actions for that combination will be executed.
    */
    public void processDomainLogicInjections(String domainProcessToken, IApplicationSObjectUnitOfWork uow )
    {
        processDomainLogicInjections( DomainProcessConstants.PROCESS_CONTEXT.DomainMethodExecution, domainProcessToken, null, uow );
    }

    public void processDomainLogicInjections(DomainProcessConstants.PROCESS_CONTEXT processContext, System.TriggerOperation triggerOperationType )
    {
        processDomainLogicInjections( processContext, triggerOperationType.name(), null, null );
    }

    /**
    *  Call this method either from a domain class method or it is automatically called from trigger context
    *  and any criteria and actions for that combination will be executed.
    */
    public void processDomainLogicInjections(DomainProcessConstants.PROCESS_CONTEXT processContext, String domainProcessToken )
    {
        processDomainLogicInjections( processContext, domainProcessToken, null, null );
    }

    /**
    *  Call this method either from a domain class method or it is automatically called from trigger context
    *  and any criteria and actions for that combination will be executed.
    */
    public void processDomainLogicInjections(String domainProcessToken, Map<Id,SObject> existingRecords )
    {
        processDomainLogicInjections( DomainProcessConstants.PROCESS_CONTEXT.DomainMethodExecution, domainProcessToken, existingRecords, null );
    }

    /**
    *  Call this method either from a domain class method or it is automatically called from trigger context
    *  and any criteria and actions for that combination will be executed.
    */
    public void processDomainLogicInjections(String domainProcessToken, Map<Id,SObject> existingRecords, IApplicationSObjectUnitOfWork uow )
    {
        processDomainLogicInjections( DomainProcessConstants.PROCESS_CONTEXT.DomainMethodExecution, domainProcessToken, existingRecords, uow );
    }

    public void processDomainLogicInjections(DomainProcessConstants.PROCESS_CONTEXT processContext, System.TriggerOperation triggerOperationType, Map<Id,SObject> existingRecords )
    {
        processDomainLogicInjections( processContext, triggerOperationType.name(), existingRecords, null );
    }

    /**
    *  Call this method either from a domain class method or it is automatically called from trigger context
    *  and any criteria and actions for that combination will be executed.
    */
    public void processDomainLogicInjections(DomainProcessConstants.PROCESS_CONTEXT processContext, String domainProcessToken, Map<Id,SObject> existingRecords )
    {
        processDomainLogicInjections( processContext, domainProcessToken, existingRecords, null );
    }

    /**
    *  Call this method either from a domain class method or it is automatically called from trigger context
    *  and any criteria and actions for that combination will be executed.
    */
    public void processDomainLogicInjections(DomainProcessConstants.PROCESS_CONTEXT processContext, String domainProcessToken, Map<Id,SObject> existingRecords, IApplicationSObjectUnitOfWork uow )
    {
        domainProcessToken = domainProcessToken.toLowerCase();
        system.debug( 'mark 1 -- processContext : ' + processContext +  ' -- domainProcessToken : ' + domainProcessToken);
        if ( getDomainProcessMap().containsKey( processContext ) )
        {
            System.debug('processContext is found and domainProcessToken was ' + (getDomainProcessMap().get( processContext ).containsKey( domainProcessToken ) ? 'found' : 'not found'));
            System.debug('processContext is found and domainProcessToken was ' + (getDomainProcessMap().get( processContext ).keySet() ) );
        }
        else 
        {
            System.debug('processContext was not found');
        }
        if ( getDomainProcessMap().containsKey( processContext )
            && getDomainProcessMap().get( processContext ).containsKey( domainProcessToken ) )
        {
            // There is a process context that matches the parameters

            // The domainProcessesToExecuteMap is comprised of the following data points:
            //  Sequence --------------------------------------------------------------- Sequence
            //  |            Type__c --------------------------------------------------- Type__c
            //  |            |                 OrderOfExecution__c --------------------- OrderOfExecution__c
            //  |            |                 |        DomainProcessBinding__mdt ------------- DomainProcessBinding__mdt
            //  |            |                 |        |
            Map<Integer, Map<DomainProcessConstants.PROCESS_TYPE, Map<Decimal, DomainProcessBinding__mdt>>> domainProcessesToExecuteMap = getDomainProcessMap().get( processContext ).get( domainProcessToken );

            List<SObject> qualifiedRecords = new List<SObject>();

            List<Integer> sequenceKeysSorted = new List<Integer>( domainProcessesToExecuteMap.keySet() );

            sequenceKeysSorted.sort();

            List<Decimal> orderOfExecutionKeysSorted = new List<Decimal>();

            Type classToInject = null;

            IDomainProcessCriteria criteriaClazz = null;
            IDomainProcessAction actionClazz = null;

            DomainProcessBinding__mdt currentDomainProcess = null;

            for( Integer sequenceKey : sequenceKeysSorted )
            {
                system.debug('Starting sequence ' + sequenceKey + ' for processContext ' + processContext + ' and domainProcessToken ' + domainProcessToken);

                // reset the qualifiedRecords
                qualifiedRecords.clear();

                // process the criterias first
                if ( domainProcessesToExecuteMap.get( sequenceKey ).containsKey( DomainProcessConstants.PROCESS_TYPE.CRITERIA ) )
                {
                    // process the criteria

                    // reset the orderOfExecutionKeysSorted
                    orderOfExecutionKeysSorted.clear();

                    orderOfExecutionKeysSorted = new List<Decimal>( domainProcessesToExecuteMap.get( sequenceKey ).get( DomainProcessConstants.PROCESS_TYPE.CRITERIA ).keySet() );

                    orderOfExecutionKeysSorted.sort();

                    qualifiedRecords.addAll( this.sObjectDomain.getRecords() );

                    for ( Decimal orderOfExecutionKey : orderOfExecutionKeysSorted )
                    {
                        currentDomainProcess = domainProcessesToExecuteMap.get( sequenceKey ).get( DomainProcessConstants.PROCESS_TYPE.CRITERIA ).get( orderOfExecutionKey );
                        system.debug( 'processing criteria class ' + currentDomainProcess.ClassToInject__c );

                        classToInject = Type.forName( currentDomainProcess.ClassToInject__c );

                        if ( classToInject == null )
                        {
                            throw new ProcessInjectionException('Unable to find class type of \'' + currentDomainProcess.ClassToInject__c + '\'');
                        }

                        try
                        {
                            // newInstance from here
                            criteriaClazz = (IDomainProcessCriteria) classToInject.newInstance();

                            criteriaClazz.setRecordsToEvaluate( qualifiedRecords );

                            if ( criteriaClazz instanceOf IDomainProcessCriteriaWithExistingRecs
                                && existingRecords != null
                                && ! existingRecords.isEmpty() )
                            {
                                ((IDomainProcessCriteriaWithExistingRecs)criteriaClazz).setExistingRecords( existingRecords );
                            }
                            // TODO: Still need to figure out how to make use of currentDomainProcess.LogicalInverse__c here.
                            qualifiedRecords = criteriaClazz.run();
                        }
                        catch (Exception e)
                        {
                            system.debug( e );
                            throw new ProcessInjectionException( e );
                        }

                        // if all records have been removed from qualification, then exit out of the loop
                        if ( qualifiedRecords.isEmpty() )
                        {
                            system.debug( 'no qualified records were found');
                            break;
                        }
                    }
                }
                else
                {
                    // no criteria found in this sequence
                    // set the qualifiedRecords to the domain's records
                    qualifiedRecords.addAll( this.sObjectDomain.getRecords() );
                }

                system.debug( logginglevel.FINE, qualifiedRecords );
                system.debug( logginglevel.FINE, sequenceKey );

                // process the actions last
                if ( domainProcessesToExecuteMap.get( sequenceKey ).containsKey( DomainProcessConstants.PROCESS_TYPE.ACTION )
                    && ! qualifiedRecords.isempty() )
                {
                    System.debug('processing actions');
                    // reset the orderOfExecutionKeysSorted
                    orderOfExecutionKeysSorted.clear();

                    orderOfExecutionKeysSorted = new List<Decimal>( domainProcessesToExecuteMap.get( sequenceKey ).get( DomainProcessConstants.PROCESS_TYPE.ACTION ).keySet() );

                    orderOfExecutionKeysSorted.sort();

                    classToInject = null;

                    for ( Decimal orderOfExecutionKey : orderOfExecutionKeysSorted )
                    {
                        currentDomainProcess = domainProcessesToExecuteMap.get( sequenceKey ).get( DomainProcessConstants.PROCESS_TYPE.ACTION ).get( orderOfExecutionKey );
                        system.debug( 'processing action class ' + currentDomainProcess.ClassToInject__c );

                        classToInject = Type.forName( currentDomainProcess.ClassToInject__c );

                        if ( classToInject == null )
                        {
                            throw new ProcessInjectionException('Unable to find class type of \'' + currentDomainProcess.ClassToInject__c + '\'');
                        }

                        try
                        {
                            // newInstance from here
                            actionClazz = (IDomainProcessAction) classToInject.newInstance();

                            actionClazz.setRecordsToActOn( qualifiedRecords );

                            // Should the action process execute in async/queueable mode?
                            if (currentDomainProcess.ExecuteAsynchronous__c != null) {
                                ((IDomainProcessQueueableAction)actionClazz).setActionToRunInQueue( currentDomainProcess.ExecuteAsynchronous__c );
                            }
                            
                            if ( actionClazz instanceOf IDomainProcessUnitOfWorkable
                                && uow != null )
                            {
                                ((IDomainProcessUnitOfWorkable)actionClazz).setUnitOfWork( uow );
                            }

                            actionClazz.run();
                        }
                        catch (Exception e)
                        {
                            system.debug( e );
                            throw new ProcessInjectionException( e );
                        }
                    }
                }
            }
        }
    }

    public class ProcessInjectionException extends Exception { }
}
