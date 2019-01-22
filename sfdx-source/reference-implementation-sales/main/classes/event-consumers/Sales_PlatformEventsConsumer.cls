public class Sales_PlatformEventsConsumer extends PlatformEventAbstractConsumer {
    public override void runInProcess() {
        System.debug('<ojs> Sales_PlatformEventsConsumer.runInProcess');
        System.debug('<ojs> events:\n' + events);

        Set<Id> idSet = new Set<Id>();

        for (SObject sobj : events) {
            Event__e evt = (Event__e) sobj;
            idSet.addAll((Set<Id>) JSON.deserialize(evt.Payload__c, Set<Id>.class));
        }

        System.debug('idSet:\n' + idSet);
    }
}