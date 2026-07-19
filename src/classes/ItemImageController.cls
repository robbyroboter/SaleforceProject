public with sharing class ItemImageController {

	@AuraEnabled
	public static void updateItemImage(Id itemId) {

		Item__c item = [
				SELECT Id, Name
				FROM Item__c
				WHERE Id = :itemId
				LIMIT 1
		];

		String imageUrl = UnsplashService.getImageUrl(item.Name);

		if (imageUrl != null) {
			item.Image__c = imageUrl;
			update item;
		}
	}
}