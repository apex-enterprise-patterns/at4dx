public class DomainProcessCoordinator 
{
    public DomainProcessCoordinator() {

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

    /**
    *  Call this method either from a domain class method or it is automatically called from trigger context
    *  and any criteria and actions for that combination will be executed.
    */
    protected void processDomainLogicInjections(DomainProcessConstants.PROCESS_CONTEXT processContext, String domainProcessToken )
    {
        processDomainLogicInjections( processContext, domainProcessToken, null, null );
    }

    /**
    *  Call this method either from a domain class method or it is automatically called from trigger context
    *  and any criteria and actions for that combination will be executed.
    */
    protected void processDomainLogicInjections(String domainProcessToken, Map<Id,SObject> existingRecords )
    {
        processDomainLogicInjections( DomainProcessConstants.PROCESS_CONTEXT.DomainMethodExecution, domainProcessToken, existingRecords, null );
    }

    /**
    *  Call this method either from a domain class method or it is automatically called from trigger context
    *  and any criteria and actions for that combination will be executed.
    */
    protected void processDomainLogicInjections(String domainProcessToken, Map<Id,SObject> existingRecords, IApplicationSObjectUnitOfWork uow )
    {
        processDomainLogicInjections( DomainProcessConstants.PROCESS_CONTEXT.DomainMethodExecution, domainProcessToken, existingRecords, uow );
    }

    /**
    *  Call this method either from a domain class method or it is automatically called from trigger context
    *  and any criteria and actions for that combination will be executed.
    */
    protected void processDomainLogicInjections(DomainProcessConstants.PROCESS_CONTEXT processContext, String domainProcessToken, Map<Id,SObject> existingRecords )
    {
        processDomainLogicInjections( processContext, domainProcessToken, existingRecords, null );
    }

    /**
    *  Call this method either from a domain class method or it is automatically called from trigger context
    *  and any criteria and actions for that combination will be executed.
    */
    protected void processDomainLogicInjections(DomainProcessConstants.PROCESS_CONTEXT processContext, String domainProcessToken, Map<Id,SObject> existingRecords, IApplicationSObjectUnitOfWork uow )
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
//             //  |            |                 |        DomainProcess__mdt ------------- DomainProcess__mdt
//             //  |            |                 |        |
//             Map<Integer, Map<DomainProcessConstants.PROCESS_TYPE, Map<Decimal, DomainProcess__mdt>>> domainProcessesToExecuteMap = getDomainProcessMap().get( processContext ).get( domainProcessToken );
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
//             DomainProcess__mdt currentDomainProcess = null;
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
