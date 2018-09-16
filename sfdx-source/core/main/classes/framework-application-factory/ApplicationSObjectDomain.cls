public abstract class ApplicationSObjectDomain 
    extends fflib_SObjectDomain
    implements IApplicationSObjectDomain
{
    public IDomainProcessCoordinator getDomainProcessCoordinator()
    {
        return (IDomainProcessCoordinator)di_Injector.Org.getInstance(IDomainProcessCoordinator.class, this);
    }

    public ApplicationSObjectDomain(List<SObject> records) {
        super(records);
        // Disable the base class CRUD checking in preference to explicit checking elsewhere
        Configuration.disableTriggerCRUDSecurity();
    }
    /*
     *  Setup the hooks for all of the various trigger contexts to process domain logic injections, if needed.
     */
    public virtual override void handleBeforeInsert()
    {
        super.handleBeforeInsert();
        this.getDomainProcessCoordinator().processDomainLogicInjections( DomainProcessConstants.PROCESS_CONTEXT.TriggerExecution, System.TriggerOperation.Before_Insert );
    }

    public virtual override void handleBeforeUpdate(Map<Id,SObject> existingRecords)
    {
        super.handleBeforeUpdate( existingRecords );
        this.getDomainProcessCoordinator().processDomainLogicInjections( DomainProcessConstants.PROCESS_CONTEXT.TriggerExecution, System.TriggerOperation.Before_Update, existingRecords );
    }

    public virtual override void handleBeforeDelete()
    {
        super.handleBeforeDelete();
        this.getDomainProcessCoordinator().processDomainLogicInjections( DomainProcessConstants.PROCESS_CONTEXT.TriggerExecution, System.TriggerOperation.Before_Delete );
    }

    public virtual override void handleAfterInsert()
    {
        super.handleAfterInsert();
        this.getDomainProcessCoordinator().processDomainLogicInjections( DomainProcessConstants.PROCESS_CONTEXT.TriggerExecution, System.TriggerOperation.After_Insert );
    }

    public virtual override void handleAfterUpdate(Map<Id,SObject> existingRecords)
    {
        super.handleAfterUpdate( existingRecords );
        this.getDomainProcessCoordinator().processDomainLogicInjections( DomainProcessConstants.PROCESS_CONTEXT.TriggerExecution, System.TriggerOperation.After_Update, existingRecords );
    }

    public virtual override void handleAfterDelete()
    {
        super.handleAfterDelete();
        this.getDomainProcessCoordinator().processDomainLogicInjections( DomainProcessConstants.PROCESS_CONTEXT.TriggerExecution, System.TriggerOperation.After_Delete );
    }

    public virtual override void handleAfterUndelete()
    {
        super.handleAfterUndelete();
        this.getDomainProcessCoordinator().processDomainLogicInjections( DomainProcessConstants.PROCESS_CONTEXT.TriggerExecution, System.TriggerOperation.After_Undelete );
    }



    /**
     *  Convenience method to expose the fflib_SObjectDomain.SObjectDescribe values to the DomainProcessCoordinator
     */
    public Schema.DescribeSObjectResult getSObjectDescribe()
    {
        return this.SObjectDescribe;
    }
}
