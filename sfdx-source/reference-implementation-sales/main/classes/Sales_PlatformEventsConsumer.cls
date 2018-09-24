public class Sales_PlatformEventsConsumer
    implements IEventsConsumer
{
    private List<SObject> eventSObjects = new List<SObject>();

    // ============ IEventsConsumer implementation ============

    public void setEvents(List<SObject> events)
    {
        System.debug('<ojs> Sales_PlatformEventsConsumer.setEvents:\n' + events);
        this.eventSobjects = events;
    }

    // ============ Queueable implementation ============

    public void execute(QueueableContext context)
    {
        System.debug('<ojs> Sales_PlatformEventsConsumer.execute');
        System.debug('<ojs> eventSobjects:\n' + eventSobjects);

        Set<Id> idSet = new Set<Id>();

        for (SObject sobj : eventSObjects)
        {
            Event__e evt = (Event__e) sobj;
            idSet.addAll((Set<Id>) JSON.deserialize(evt.Payload__c, Set<Id>.class));
        }

        System.debug('idSet:\n' + idSet);
    }
}