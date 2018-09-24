public interface IEventsConsumer
    extends Queueable
{
    void setEvents(List<Sobject> events);
}
