public class DomainProcessCoordinator 
{
    private Schema.DescribeSObjectResult sObjectDescribe = null;

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
        // find all process DomainProcessBinding__mdt records that are related
        list<DomainProcessBinding__mdt> domainProcesses = [select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName
                                                         , ClassToInject__c, Description__c, DomainMethodToken__c, ExecuteAsynchronous__c, IsActive__c
                                                         , LogicalInverse__c, OrderOfExecution__c, PreventRecursive__c, ProcessContext__c
                                                         , RelatedDomainBindingSObject__c, TriggerOperation__c, Type__c
                                                      from DomainProcessBinding__mdt
                                                     where RelatedDomainBindingSObject__c = :this.sObjectDescribe.getName()
                                                       and IsActive__c = true
                                                     order by ProcessContext__c, TriggerOperation__c, OrderOfExecution__c, Type__c];

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

            domainProcessToken = string.isBlank( domainProcess.DomainMethodToken__c ) ? domainProcess.TriggerOperation__c : domainProcess.DomainMethodToken__c;

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

    public DomainProcessCoordinator(Schema.DescribeSObjectResult sObjectDescribe) 
    {
        if ( sObjectDescribe == null )
        {

        }
        this.sObjectDescribe = sObjectDescribe;
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
    }
//         system.debug( 'mark 1 -- processContext : ' + processContext +  ' -- domainProcessToken : ' + domainProcessToken);
//         if ( getDomainProcessMap().containsKey( processContext )
//             && getDomainProcessMap().get( processContext ).containsKey( domainProcessToken ) )
//         {
//             // There is a process context that matches the parameters
// 
//             // The domainProcessesToExecuteMap is comprised of the following data points:
//             //  Sequence --------------------------------------------------------------- Sequence
//             //  |            Type__c --------------------------------------------------- Type__c
//             //  |            |                 OrderOfExecution__c --------------------- OrderOfExecution__c
//             //  |            |                 |        DomainProcessBinding__mdt ------------- DomainProcessBinding__mdt
//             //  |            |                 |        |
//             Map<Integer, Map<DomainProcessConstants.PROCESS_TYPE, Map<Decimal, DomainProcessBinding__mdt>>> domainProcessesToExecuteMap = getDomainProcessMap().get( processContext ).get( domainProcessToken );
// 
//             List<SObject> qualifiedRecords = new List<SObject>();
// 
//             List<Integer> sequenceKeysSorted = new List<Integer>( domainProcessesToExecuteMap.keySet() );
// 
//             sequenceKeysSorted.sort();
// 
//             List<Decimal> orderOfExecutionKeysSorted = new List<Decimal>();
// 
//             Type classToInject = null;
// 
//             mmlib_ICriteria criteriaClazz = null;
//             mmlib_IAction actionClazz = null;
// 
//             DomainProcessBinding__mdt currentDomainProcess = null;
// 
//             for( Integer sequenceKey : sequenceKeysSorted )
//             {
//                 system.debug('Starting sequence ' + sequenceKey + ' for processContext ' + processContext + ' and domainProcessToken ' + domainProcessToken);
// 
//                 // reset the qualifiedRecords
//                 qualifiedRecords.clear();
// 
//                 // process the criterias first
//                 if ( domainProcessesToExecuteMap.get( sequenceKey ).containsKey( DomainProcessConstants.PROCESS_TYPE.CRITERIA ) )
//                 {
//                     // process the criteria
// 
//                     // reset the orderOfExecutionKeysSorted
//                     orderOfExecutionKeysSorted.clear();
// 
//                     orderOfExecutionKeysSorted = new List<Decimal>( domainProcessesToExecuteMap.get( sequenceKey ).get( DomainProcessConstants.PROCESS_TYPE.CRITERIA ).keySet() );
// 
//                     orderOfExecutionKeysSorted.sort();
// 
//                     qualifiedRecords.addAll( this.records );
// 
//                     for ( Decimal orderOfExecutionKey : orderOfExecutionKeysSorted )
//                     {
//                         currentDomainProcess = domainProcessesToExecuteMap.get( sequenceKey ).get( DomainProcessConstants.PROCESS_TYPE.CRITERIA ).get( orderOfExecutionKey );
//                         system.debug( 'processing criteria class ' + currentDomainProcess.ClassToInject__c );
// 
//                         classToInject = Type.forName( currentDomainProcess.ClassToInject__c );
// 
//                         if ( classToInject == null )
//                         {
//                             throw new ProcessInjectionException('Unable to find class type of \'' + currentDomainProcess.ClassToInject__c + '\'');
//                         }
// 
//                         try
//                         {
//                             // newInstance from here
//                             criteriaClazz = (mmlib_ICriteria) classToInject.newInstance();
// 
//                             criteriaClazz.setRecordsToEvaluate( qualifiedRecords );
// 
//                             if ( criteriaClazz instanceOf mmlib_ICriteriaWithExistingRecords
//                                 && existingRecords != null
//                                 && ! existingRecords.isEmpty() )
//                             {
//                                 ((mmlib_ICriteriaWithExistingRecords)criteriaClazz).setExistingRecords( existingRecords );
//                             }
// // TODO: Still need to figure out how to make use of currentDomainProcess.LogicalInverse__c here.
//                             qualifiedRecords = criteriaClazz.run();
//                         }
//                         catch (Exception e)
//                         {
//                             system.debug( e );
//                             throw new ProcessInjectionException( e );
//                         }
// 
//                         // if all records have been removed from qualification, then exit out of the loop
//                         if ( qualifiedRecords.isEmpty() )
//                         {
//                             system.debug( 'no qualified records were found');
//                             break;
//                         }
//                     }
//                 }
//                 else
//                 {
//                     // no criteria found in this sequence
//                     // set the qualifiedRecords to the domain's records
//                     qualifiedRecords.addAll( this.records );
//                 }
// 
//                 system.debug( logginglevel.FINE, qualifiedRecords );
//                 system.debug( logginglevel.FINE, sequenceKey );
// 
//                 // process the actions last
//                 if ( domainProcessesToExecuteMap.get( sequenceKey ).containsKey( DomainProcessConstants.PROCESS_TYPE.ACTION )
//                     && ! qualifiedRecords.isempty() )
//                 {
//                     System.debug('processing actions');
//                     // reset the orderOfExecutionKeysSorted
//                     orderOfExecutionKeysSorted.clear();
// 
//                     orderOfExecutionKeysSorted = new List<Decimal>( domainProcessesToExecuteMap.get( sequenceKey ).get( DomainProcessConstants.PROCESS_TYPE.ACTION ).keySet() );
// 
//                     orderOfExecutionKeysSorted.sort();
// 
//                     classToInject = null;
// 
//                     for ( Decimal orderOfExecutionKey : orderOfExecutionKeysSorted )
//                     {
//                         currentDomainProcess = domainProcessesToExecuteMap.get( sequenceKey ).get( DomainProcessConstants.PROCESS_TYPE.ACTION ).get( orderOfExecutionKey );
//                         system.debug( 'processing action class ' + currentDomainProcess.ClassToInject__c );
// 
//                         classToInject = Type.forName( currentDomainProcess.ClassToInject__c );
// 
//                         if ( classToInject == null )
//                         {
//                             throw new ProcessInjectionException('Unable to find class type of \'' + currentDomainProcess.ClassToInject__c + '\'');
//                         }
// 
//                         try
//                         {
//                             // newInstance from here
//                             actionClazz = (mmlib_IAction) classToInject.newInstance();
// 
//                             actionClazz.setRecordsToActOn( qualifiedRecords );
// 
//                             // Should the action process execute in async/queueable mode?
//                             if ( currentDomainProcess.ExecuteAsynchronous__c )
//                             {
//                                 ((mmlib_IQueueableAction)actionClazz).setActionToRunInQueue( true );
//                             }
// 
//                             if ( actionClazz instanceOf mmlib_IUnitOfWorkable
//                                 && uow != null )
//                             {
//                                 ((mmlib_IUnitOfWorkable)actionClazz).setUnitOfWork( uow );
//                             }
// 
//                             actionClazz.run();
//                         }
//                         catch (Exception e)
//                         {
//                             system.debug( e );
//                             throw new ProcessInjectionException( e );
//                         }
//                     }
//                 }
//             }
//         }
//     }
// 
//     public class ProcessInjectionException extends Exception { }


}
