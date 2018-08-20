/**
 *  IApplicationSObjectUnitOfWork
 */
public interface IApplicationSObjectUnitOfWork
    extends fflib_ISObjectUnitOfWork
{
    list<SObject> getNewRecordsByType( Schema.SObjectType typeToFind );
    Map<Id, SObject> getDirtyRecordsByType( Schema.SObjectType typeToFind );
    Map<Id, SObject> getDeletedRecordsByType( Schema.SObjectType typeToFind );

    /**
     * Register a SObject instance to be either inserted or updated when commitWork is called
     *
     * @param record A SObject instance to be inserted or updated during commitWork
     **/
    void register(SObject record);

    /**
     * Register a list of SObject instances to be either inserted or updated when commitWork is called
     *
     * @param records A list SObject instances to be either inserted or updated during commitWork
     **/
    void register(List<SObject> records);

    void register(SObject record, Schema.sObjectField relatedToParentField, SObject relatedToParentRecord);

    /**
     * Registers a group of emails to be sent during the commitWork
     **/
    void registerEmails( list<Messaging.Email> emails );


    /**
     * Register platform events to be emitted prior to the beginning of the data base transaction
     */
    void registerPublishBeforeTransaction( List<SObject> events );

    /**
     * Register platform events to be emitted after the conclusion of the data base transaction if it is successful
     */
    void registerPublishAfterTransactionSuccess( List<SObject> events );

    /**
     * Register platform events to be emitted after the conclusion of the data base transaction if it fails
     */
    void registerPublishAfterTransactionFailure( List<SObject> events );
}