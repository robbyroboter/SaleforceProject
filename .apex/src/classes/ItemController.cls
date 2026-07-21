public with sharing class ItemController {

	@AuraEnabled(cacheable=true)
	public static List<Item__c> getItems(
			String familyFilter,
			String typeFilter,
			String searchText
			) {

		String query =
				'SELECT Id, Name, Description__c, Type__c, Family__c, ' +
				'Image__c, Price__c, AvailableQuantity__c ' +
				'FROM Item__c WHERE Id != null';

		if (String.isNotBlank(familyFilter)) {
			query += ' AND Family__c = :familyFilter';
		}

		if (String.isNotBlank(typeFilter)) {
			query += ' AND Type__c = :typeFilter';
		}

		if (String.isNotBlank(searchText)) {
			String likeText = '%' + String.escapeSingleQuotes(searchText) + '%';

			query +=
					' AND (Name LIKE :likeText ' +
					' OR Description__c LIKE :likeText)';
		}

		query += ' ORDER BY Name';

		return Database.query(query);
	}

	@AuraEnabled(cacheable=true)
	public static Item__c getItemById(Id itemId) {

		if (itemId == null) {
			return null;
		}

		List<Item__c> items = [
				SELECT Id,
						Name,
						Description__c,
						Type__c,
						Family__c,
						Image__c,
						Price__c,
						AvailableQuantity__c
				FROM Item__c
				WHERE Id = :itemId
				LIMIT 1
		];

		return items.isEmpty() ? null : items[0];
	}
}