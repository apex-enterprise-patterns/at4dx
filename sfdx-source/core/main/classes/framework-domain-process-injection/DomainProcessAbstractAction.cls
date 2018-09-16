public abstract class DomainProcessAbstractAction
    implements IDomainProcessAction, IDomainProcessQueueableAction, Queueable, IDomainProcessUnitOfWorkable
{
    private boolean isActionToRunInQueue = false;
    private IDomainProcessQueueableAction nextQueueableAction = null;
    private Boolean isRecordsRequired = true;

    protected List<SObject> records = new List<SObject>();
    protected IApplicationSObjectUnitOfWork uow = null;

    public DomainProcessAbstractAction setActionToRunInQueue( boolean isActionToRunInQueue )
    {
        this.isActionToRunInQueue = isActionToRunInQueue;

        return this;
    }

    public DomainProcessAbstractAction setNextQueueableActionInChain( IDomainProcessQueueableAction nextQueueableAction )
    {
        this.nextQueueableAction = nextQueueableAction;

        return this;
    }

    public DomainProcessAbstractAction setRecordsRequired( Boolean isRecordsRequired )
    {
        this.isRecordsRequired = isRecordsRequired;

        return this;
    }

    public IDomainProcessQueueableAction getNextQueuableAction()
    {
        return this.nextQueueableAction;
    }

    public IDomainProcessAction setRecordsToActOn( List<SObject> records )
    {
        this.records = records;

        return this;
    }

    public IDomainProcessUnitOfWorkable setUnitOfWork( IApplicationSObjectUnitOfWork uow )
    {
        this.uow = uow;

        return this;
    }

    public void run()
    {
        if ( ( isRecordsRequired && ! this.records.isEmpty() )
            || ! isRecordsRequired )
        {
            if (this.isActionToRunInQueue)
            {
                // Send it to the queue for processing later
                System.enqueueJob( this );
            }
            else
            {
                runInProcess();
            }
        }
    }

    public void execute(QueueableContext context)
    {
        try
        {
            this.uow = Application.UnitOfWork.newInstance();

            runInProcess();

            this.uow.commitWork();
        }
        catch (Exception e)
        {
            system.debug(e);
            system.debug(e.getStackTraceString());
        }

        if (getNextQueuableAction() != null)
        {
            System.enqueueJob( getNextQueuableAction() );
        }
    }

    public abstract void runInProcess();
}