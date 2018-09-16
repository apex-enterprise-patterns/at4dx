public interface IDomainProcessCoordinator 
{
    void processDomainLogicInjections(String domainProcessToken );
    void processDomainLogicInjections(String domainProcessToken, IApplicationSObjectUnitOfWork uow );
    void processDomainLogicInjections(DomainProcessConstants.PROCESS_CONTEXT processContext, System.TriggerOperation triggerOperationType );
    void processDomainLogicInjections(DomainProcessConstants.PROCESS_CONTEXT processContext, System.TriggerOperation triggerOperationType, Map<Id, SObject> existingRecords );
}
