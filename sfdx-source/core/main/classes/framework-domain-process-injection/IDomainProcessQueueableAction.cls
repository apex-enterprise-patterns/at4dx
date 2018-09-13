/**
 *  IDomainProcessQueueableAction
 */
public interface IDomainProcessQueueableAction
{
    IDomainProcessQueueableAction setActionToRunInQueue( boolean isActionToRunInQueue );

    IDomainProcessQueueableAction setNextQueueableActionInChain( IDomainProcessQueueableAction nextAction );

    IDomainProcessQueueableAction getNextQueuableAction();
}