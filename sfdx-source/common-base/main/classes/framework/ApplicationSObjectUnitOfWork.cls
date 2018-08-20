/**
 *  ApplicationSObjectUnitOfWork
 */
public class ApplicationSObjectUnitOfWork
    extends fflib_SObjectUnitOfWork
    implements IApplicationSObjectUnitOfWork
{
    private list<SObject> eventsToEmitBeforeTransaction = new list<SObject>();
    private list<SObject> eventsToEmitAfterTransactionSucceeds = new list<SObject>();
    private list<SObject> eventsToEmitAfterTransactionFails = new list<SObject>();

    public ApplicationSObjectUnitOfWork( List<Schema.SObjectType> sObjectTypes )
    {
        super(sObjectTypes);
    }

    public ApplicationSObjectUnitOfWork(List<Schema.SObjectType> sObjectTypes, fflib_SObjectUnitOfWork.IDML dml)
    {
        super(sObjectTypes, dml);
    }

    public list<SObject> getNewRecordsByType( Schema.SObjectType typeToFind )
    {
        return typeToFind == null ? null : m_newListByType.get( typeToFind.getDescribe().getName() );
    }

    public Map<Id, SObject> getDirtyRecordsByType( Schema.SObjectType typeToFind )
    {
        return typeToFind == null ? null : m_dirtyMapByType.get( typeToFind.getDescribe().getName() );
    }

    public Map<Id, SObject> getDeletedRecordsByType( Schema.SObjectType typeToFind )
    {
        return typeToFind == null ? null : m_deletedMapByType.get( typeToFind.getDescribe().getName() );
    }

    public override void onCommitWorkStarting() 
    {
        if ( ! this.eventsToEmitBeforeTransaction.isEmpty() )
        {
             EventBus.publish( this.eventsToEmitBeforeTransaction );
        }
    }

    public override void onCommitWorkFinished(Boolean wasSuccessful) 
    {
        if ( wasSuccessful && ! this.eventsToEmitAfterTransactionSucceeds.isEmpty() )
        {
            EventBus.publish( eventsToEmitAfterTransactionSucceeds );
        }
        else if ( ! wasSuccessful && ! this.eventsToEmitAfterTransactionFails.isEmpty() )
        {
            EventBus.publish( eventsToEmitAfterTransactionFails );
        }
    }

    public void register(SObject record)
    {
        if ( record != null )
        {
            if ( record.id == null )
            {
                this.registerNew( record );
            }
            else
            {
                this.registerDirty( record );
            }
        }
    }

    public void register(List<SObject> records)
    {
        if ( records != null )
        {
            for ( SObject record : records )
            {
                if ( record.id == null )
                {
                    this.registerNew( record );
                }
                else
                {
                    this.registerDirty( record );
                }
            }
        }
    }

    public void register(SObject record, Schema.sObjectField relatedToParentField, SObject relatedToParentRecord)
    {
        if ( record != null )
        {
            if ( record.id == null )
            {
                this.registerNew( record, relatedToParentField, relatedToParentRecord);
            }
            else
            {
                this.registerDirty( record, relatedToParentField, relatedToParentRecord);
            }
        }

    }

    /**
     * Registers a group of emails to be sent during the commitWork
     **/
    public void registerEmails( list<Messaging.Email> emails )
    {
        if ( emails != null )
        {
            for ( Messaging.Email email : emails )
            {
                this.registerEmail(email);
            }
        }
    }

    /**
     * Register platform events to be emitted prior to the beginning of the data base transaction
     */
    public void registerPublishBeforeTransaction( List<SObject> events )
    {
        this.eventsToEmitBeforeTransaction.addAll( events );
    }

    /**
     * Register platform events to be emitted after the conclusion of the data base transaction if it is successful
     */
    public void registerPublishAfterTransactionSuccess( List<SObject> events )
    {
        this.eventsToEmitAfterTransactionSucceeds.addAll( events );
    }

    /**
     * Register platform events to be emitted after the conclusion of the data base transaction if it fails
     */
    public void registerPublishAfterTransactionFailure( List<SObject> events )
    {
        this.eventsToEmitAfterTransactionFails.addAll( events );
    }
}