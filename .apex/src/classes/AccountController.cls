public with sharing class AccountController {

	@AuraEnabled(cacheable=true)
	public static Account getAccountInfo(Id accountId) {

		return [
				SELECT
						Id,
						Name,
						AccountNumber,
						Industry
				FROM Account
				WHERE Id = :accountId
				LIMIT 1
		];
	}
}