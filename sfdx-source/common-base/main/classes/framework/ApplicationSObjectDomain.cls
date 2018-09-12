public abstract class ApplicationSObjectDomain 
    extends fflib_SObjectDomain
    implements IApplicationSObjectDomain
{
    private DomainProcessCoordinator dpc = null;

    public ApplicationSObjectDomain(List<SObject> records) {
        super(records);
        // Disable the base class CRUD checking in preference to explicit checking elsewhere
        Configuration.disableTriggerCRUDSecurity();
        this.dpc = new DomainProcessCoordinator( this.SObjectDescribe );
    }
    /*
     *  Setup the hooks for all of the various trigger contexts to process domain logic injections, if needed.
     */
    public virtual override void handleBeforeInsert()
    {
        super.handleBeforeInsert();
        this.dpc.processDomainLogicInjections( DomainProcessConstants.PROCESS_CONTEXT.TriggerExecution, System.TriggerOperation.Before_Insert );
    }

    public virtual override void handleBeforeUpdate(Map<Id,SObject> existingRecords)
    {
        super.handleBeforeUpdate( existingRecords );
        this.dpc.processDomainLogicInjections( DomainProcessConstants.PROCESS_CONTEXT.TriggerExecution, System.TriggerOperation.Before_Update, existingRecords );
    }

    public virtual override void handleBeforeDelete()
    {
        super.handleBeforeDelete();
        this.dpc.processDomainLogicInjections( DomainProcessConstants.PROCESS_CONTEXT.TriggerExecution, System.TriggerOperation.Before_Delete );
    }

    public virtual override void handleAfterInsert()
    {
        super.handleAfterInsert();
        this.dpc.processDomainLogicInjections( DomainProcessConstants.PROCESS_CONTEXT.TriggerExecution, System.TriggerOperation.After_Insert );
    }

    public virtual override void handleAfterUpdate(Map<Id,SObject> existingRecords)
    {
        super.handleAfterUpdate( existingRecords );
        this.dpc.processDomainLogicInjections( DomainProcessConstants.PROCESS_CONTEXT.TriggerExecution, System.TriggerOperation.After_Update, existingRecords );
    }

    public virtual override void handleAfterDelete()
    {
        super.handleAfterDelete();
        this.dpc.processDomainLogicInjections( DomainProcessConstants.PROCESS_CONTEXT.TriggerExecution, System.TriggerOperation.After_Delete );
    }

    public virtual override void handleAfterUndelete()
    {
        super.handleAfterUndelete();
        this.dpc.processDomainLogicInjections( DomainProcessConstants.PROCESS_CONTEXT.TriggerExecution, System.TriggerOperation.After_Undelete );
    }
}
