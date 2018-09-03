public abstract class ApplicationSObjectDomain 
    extends fflib_SObjectDomain
    implements IApplicationSObjectDomain
{
    public ApplicationSObjectDomain(List<SObject> records) {
        super(records);
        // Disable the base class CRUD checking in preference to explicit checking elsewhere
        Configuration.disableTriggerCRUDSecurity();
    }

    public class ProcessInjectionException extends Exception { }
}
// public virtual class mmlib_SObjectDomain
//     extends fflib_SObjectDomain
//     implements mmlib_ISObjectDomain
// {
// 
//     // The domainProcessMap organizes all of the domain process custom metadata record entries
//     // The map is organized by ProcessContext__c, DomainMethodToken__c/TriggerOperation__c, "Sequence" (infered from the OrderOfExecution__c), Type__c, OrderOfExecution__c, --- DomainProcess__mdt record which contains the ClassToInject__c
//     private Map<mmlib_DomainProcessConstants.PROCESS_CONTEXT, Map<String, Map<Integer, Map<mmlib_DomainProcessConstants.PROCESS_TYPE, Map<Decimal, DomainProcess__mdt>>>>> domainProcessMap = new Map<mmlib_DomainProcessConstants.PROCESS_CONTEXT, Map<String, Map<Integer, Map<mmlib_DomainProcessConstants.PROCESS_TYPE, Map<Decimal, DomainProcess__mdt>>>>>();
// 
//     private Map<mmlib_DomainProcessConstants.PROCESS_CONTEXT, Map<String, Map<Integer, Map<mmlib_DomainProcessConstants.PROCESS_TYPE, Map<Decimal, DomainProcess__mdt>>>>> getDomainProcessMap()
//     {
//         //system.debug( 'getDomainProcessMap() called');
//         if ( domainProcessMap.isEmpty() )
//         {
//             system.debug( 'domainProcessMap found to be empty.  Now prime the relevant Domain Logic Injections records');
//             primeDomainLogicInjections();
//             //system.debug( '\n\n\n' + domainProcessMap + '\n\n\n');
//         }
//         return domainProcessMap;
//     }
// 
//     @TestVisible
//     private list<DomainProcess__mdt> mockDomainProcesses = new list<DomainProcess__mdt>();
// 
//     private void primeDomainLogicInjections()
//     {
//         // find all process DomainProcess__mdt records that are related
// 
//         list<DomainProcess__mdt> domainProcesses = [select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName
//                                                          , ClassToInject__c, Description__c, DomainMethodToken__c, ExecuteAsynchronous__c, IsActive__c
//                                                          , LogicalInverse__c, OrderOfExecution__c, PreventRecursive__c, ProcessContext__c
//                                                          , RelatedDomain__c, TriggerOperation__c, Type__c
//                                                       from DomainProcess__mdt
//                                                      where RelatedDomain__c = :SObjectDescribe.getName()
//                                                        and IsActive__c = true
//                                                      order by ProcessContext__c, TriggerOperation__c, OrderOfExecution__c, Type__c];
// 
//         //if (System.Test.isRunningTest() && mockDomainProcesses != null)
//         //system.debug( 'this.mockDomainProcesses == ' + this.mockDomainProcesses );
//         if ( ! this.mockDomainProcesses.isEmpty() )
//         {
//             domainProcesses.clear();
//             domainProcesses.addAll( mockDomainProcesses );
//             //system.debug( 'this.mockDomainProcesses == ' + this.mockDomainProcesses );
//         }
// 
//         mmlib_DomainProcessConstants.PROCESS_CONTEXT processContext = null;
//         String domainProcessToken = null;
//         Integer sequence = null;
//         mmlib_DomainProcessConstants.PROCESS_TYPE processType = null;
// 
//         // need to sort these domainProcesses by ProcessContext__c, DomainMethodToken__c/TriggerOperation__c, "Sequence" (infered from the OrderOfExecution__c), Type__c, OrderOfExecution__c, --- ClassToInject__c
//         //                                    map< string,          map< string,                              map< integer,                                      map< string, map< decimal, String> > > > >
//         for ( DomainProcess__mdt domainProcess : domainProcesses )
//         {
//             processContext = mmlib_DomainProcessConstants.PROCESS_CONTEXT.TriggerExecution.name().equalsIgnoreCase( domainProcess.ProcessContext__c ) ? mmlib_DomainProcessConstants.PROCESS_CONTEXT.TriggerExecution : mmlib_DomainProcessConstants.PROCESS_CONTEXT.DomainMethodExecution;
// 
//             if ( ! domainProcessMap.containsKey( processContext ) )
//             {
//                 domainProcessMap.put( processContext, new Map<String, Map<Integer, Map<mmlib_DomainProcessConstants.PROCESS_TYPE, Map<Decimal, DomainProcess__mdt>>>>() );
//             }
// 
//             domainProcessToken = string.isBlank( domainProcess.DomainMethodToken__c ) ? domainProcess.TriggerOperation__c : domainProcess.DomainMethodToken__c;
// 
//             if ( ! domainProcessMap.get( processContext ).containsKey( domainProcessToken ) )
//             {
//                 domainProcessMap.get( processContext ).put( domainProcessToken, new Map<Integer, Map<mmlib_DomainProcessConstants.PROCESS_TYPE, Map<Decimal, DomainProcess__mdt>>>() );
//             }
// 
//             sequence = Integer.valueOf( domainProcess.OrderOfExecution__c );
// 
//             if ( ! domainProcessMap.get( processContext ).get( domainProcessToken ).containsKey( sequence ) )
//             {
//                 domainProcessMap.get( processContext ).get( domainProcessToken ).put( sequence, new Map<mmlib_DomainProcessConstants.PROCESS_TYPE, Map<Decimal, DomainProcess__mdt>>() );
//             }
// 
//             processType = mmlib_DomainProcessConstants.PROCESS_TYPE.CRITERIA.name().equalsIgnoreCase( domainProcess.Type__c ) ? mmlib_DomainProcessConstants.PROCESS_TYPE.CRITERIA : mmlib_DomainProcessConstants.PROCESS_TYPE.ACTION;
// 
//             if ( ! domainProcessMap.get( processContext ).get( domainProcessToken ).get( sequence ).containsKey( processType ) )
//             {
//                 domainProcessMap.get( processContext ).get( domainProcessToken ).get( sequence ).put( processType, new Map<Decimal, DomainProcess__mdt>() );
//             }
// 
//             domainProcessMap.get( processContext ).get( domainProcessToken ).get( sequence ).get( processType ).put( domainProcess.OrderOfExecution__c, domainProcess );
//         }
//     }
// 
//     /***********************************************
//      *
//      *  Constructors
//      *
//      ***********************************************
//      */
//     /**
//      *  Primary constructor
//      *
//      *  @param list of SObjects
//      */
//     public mmlib_SObjectDomain(List<SObject> sObjectList)
//     {
//         super( sObjectList );
//         // default all that make use of this
//         system.debug('mmlib_SObjectDomain constructor has been called.');
// 
//     }
// 
//     /*
//      *  Setup the hooks for all of the various trigger contexts to process domain logic injections, if needed.
//      */
//     public virtual override void handleBeforeInsert()
//     {
//         system.debug( 'mmlib_SObjectDomain handleBeforeInsert is called for ' + this.records.getSobjectType() );
//         super.handleBeforeInsert();
//         processDomainLogicInjections( mmlib_DomainProcessConstants.PROCESS_CONTEXT.TriggerExecution, 'BeforeInsert' );
//     }
// 
//     public virtual override void handleBeforeUpdate(Map<Id,SObject> existingRecords)
//     {
//         system.debug( 'mmlib_SObjectDomain handleBeforeUpdate is called for ' + this.records.getSobjectType() );
//         super.handleBeforeUpdate( existingRecords );
//         processDomainLogicInjections( mmlib_DomainProcessConstants.PROCESS_CONTEXT.TriggerExecution, 'BeforeUpdate', existingRecords );
//     }
// 
//     public virtual override void handleBeforeDelete()
//     {
//         system.debug( 'mmlib_SObjectDomain handleBeforeDelete is called');
//         super.handleBeforeDelete();
//         processDomainLogicInjections( mmlib_DomainProcessConstants.PROCESS_CONTEXT.TriggerExecution, 'BeforeDelete' );
//     }
// 
//     public virtual override void handleAfterInsert()
//     {
//         system.debug( 'mmlib_SObjectDomain handleAfterInsert is called for ' + this.records.getSobjectType() );
//         super.handleAfterInsert();
//         processDomainLogicInjections( mmlib_DomainProcessConstants.PROCESS_CONTEXT.TriggerExecution, 'AfterInsert' );
//     }
// 
//     public virtual override void handleAfterUpdate(Map<Id,SObject> existingRecords)
//     {
//         system.debug( 'mmlib_SObjectDomain handleAfterUpdate is called for ' + this.records.getSobjectType() );
//         super.handleAfterUpdate( existingRecords );
//         processDomainLogicInjections( mmlib_DomainProcessConstants.PROCESS_CONTEXT.TriggerExecution, 'AfterUpdate', existingRecords );
//     }
// 
//     public virtual override void handleAfterDelete()
//     {
//         system.debug( 'mmlib_SObjectDomain handleAfterDelete is called');
//         super.handleAfterDelete();
//         processDomainLogicInjections( mmlib_DomainProcessConstants.PROCESS_CONTEXT.TriggerExecution, 'AfterDelete' );
//     }
// 
//     public virtual override void handleAfterUndelete()
//     {
//         system.debug( 'mmlib_SObjectDomain handleAfterUndelete is called');
//         super.handleAfterUndelete();
//         processDomainLogicInjections( mmlib_DomainProcessConstants.PROCESS_CONTEXT.TriggerExecution, 'AfterUndelete' );
//     }
// 
// 
//     /**
//      *  Call this method either from a domain class method or it is automatically called from trigger context
//      *  and any criteria and actions for that combination will be executed.
//      */
//     public void processDomainLogicInjections(String domainProcessToken )
//     {
//         processDomainLogicInjections( mmlib_DomainProcessConstants.PROCESS_CONTEXT.DomainMethodExecution, domainProcessToken, null, null );
//     }
// 
//     /**
//      *  Call this method either from a domain class method or it is automatically called from trigger context
//      *  and any criteria and actions for that combination will be executed.
//      */
//     public void processDomainLogicInjections(String domainProcessToken, mmlib_ISObjectUnitOfWork uow )
//     {
//         processDomainLogicInjections( mmlib_DomainProcessConstants.PROCESS_CONTEXT.DomainMethodExecution, domainProcessToken, null, uow );
//     }
// 
//     /**
//      *  Call this method either from a domain class method or it is automatically called from trigger context
//      *  and any criteria and actions for that combination will be executed.
//      */
//     protected void processDomainLogicInjections(mmlib_DomainProcessConstants.PROCESS_CONTEXT processContext, String domainProcessToken )
//     {
//         processDomainLogicInjections( processContext, domainProcessToken, null, null );
//     }
// 
//     /**
//      *  Call this method either from a domain class method or it is automatically called from trigger context
//      *  and any criteria and actions for that combination will be executed.
//      */
//     protected void processDomainLogicInjections(String domainProcessToken, Map<Id,SObject> existingRecords )
//     {
//         processDomainLogicInjections( mmlib_DomainProcessConstants.PROCESS_CONTEXT.DomainMethodExecution, domainProcessToken, existingRecords, null );
//     }
// 
//     /**
//      *  Call this method either from a domain class method or it is automatically called from trigger context
//      *  and any criteria and actions for that combination will be executed.
//      */
//     protected void processDomainLogicInjections(String domainProcessToken, Map<Id,SObject> existingRecords, mmlib_ISObjectUnitOfWork uow )
//     {
//         processDomainLogicInjections( mmlib_DomainProcessConstants.PROCESS_CONTEXT.DomainMethodExecution, domainProcessToken, existingRecords, uow );
//     }
// 
//     /**
//      *  Call this method either from a domain class method or it is automatically called from trigger context
//      *  and any criteria and actions for that combination will be executed.
//      */
//     protected void processDomainLogicInjections(mmlib_DomainProcessConstants.PROCESS_CONTEXT processContext, String domainProcessToken, Map<Id,SObject> existingRecords )
//     {
//         processDomainLogicInjections( processContext, domainProcessToken, existingRecords, null );
//     }
// 
//     /**
//      *  Call this method either from a domain class method or it is automatically called from trigger context
//      *  and any criteria and actions for that combination will be executed.
//      */
//     protected void processDomainLogicInjections(mmlib_DomainProcessConstants.PROCESS_CONTEXT processContext, String domainProcessToken, Map<Id,SObject> existingRecords, mmlib_ISObjectUnitOfWork uow )
//     {
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
//             Map<Integer, Map<mmlib_DomainProcessConstants.PROCESS_TYPE, Map<Decimal, DomainProcess__mdt>>> domainProcessesToExecuteMap = getDomainProcessMap().get( processContext ).get( domainProcessToken );
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
//                 if ( domainProcessesToExecuteMap.get( sequenceKey ).containsKey( mmlib_DomainProcessConstants.PROCESS_TYPE.CRITERIA ) )
//                 {
//                     // process the criteria
// 
//                     // reset the orderOfExecutionKeysSorted
//                     orderOfExecutionKeysSorted.clear();
// 
//                     orderOfExecutionKeysSorted = new List<Decimal>( domainProcessesToExecuteMap.get( sequenceKey ).get( mmlib_DomainProcessConstants.PROCESS_TYPE.CRITERIA ).keySet() );
// 
//                     orderOfExecutionKeysSorted.sort();
// 
//                     qualifiedRecords.addAll( this.records );
// 
//                     for ( Decimal orderOfExecutionKey : orderOfExecutionKeysSorted )
//                     {
//                         currentDomainProcess = domainProcessesToExecuteMap.get( sequenceKey ).get( mmlib_DomainProcessConstants.PROCESS_TYPE.CRITERIA ).get( orderOfExecutionKey );
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
//                 if ( domainProcessesToExecuteMap.get( sequenceKey ).containsKey( mmlib_DomainProcessConstants.PROCESS_TYPE.ACTION )
//                     && ! qualifiedRecords.isempty() )
//                 {
//                     System.debug('processing actions');
//                     // reset the orderOfExecutionKeysSorted
//                     orderOfExecutionKeysSorted.clear();
// 
//                     orderOfExecutionKeysSorted = new List<Decimal>( domainProcessesToExecuteMap.get( sequenceKey ).get( mmlib_DomainProcessConstants.PROCESS_TYPE.ACTION ).keySet() );
// 
//                     orderOfExecutionKeysSorted.sort();
// 
//                     classToInject = null;
// 
//                     for ( Decimal orderOfExecutionKey : orderOfExecutionKeysSorted )
//                     {
//                         currentDomainProcess = domainProcessesToExecuteMap.get( sequenceKey ).get( mmlib_DomainProcessConstants.PROCESS_TYPE.ACTION ).get( orderOfExecutionKey );
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
// }