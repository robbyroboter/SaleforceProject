public with sharing class UserController {

	@AuraEnabled(cacheable=true)
	public static Boolean isCurrentUserManager() {

		User currentUser = [
				SELECT IsManager__c
				FROM User
				WHERE Id = :UserInfo.getUserId()
				LIMIT 1
		];

		return currentUser.IsManager__c;
	}
}