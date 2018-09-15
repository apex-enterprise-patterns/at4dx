public interface IApplicationSObjectDomain 
    extends fflib_ISObjectDomain
{
    IDomainProcessCoordinator getDomainProcessCoordinator();
    Schema.DescribeSObjectResult getSObjectDescribe();
}