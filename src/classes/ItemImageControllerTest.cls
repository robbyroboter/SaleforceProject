@IsTest
private class ItemImageControllerTest {

	private class UnsplashMock implements HttpCalloutMock {

		public HTTPResponse respond(HTTPRequest request) {

			HttpResponse response = new HttpResponse();

			response.setStatusCode(200);

			response.setBody(
							'{' +
							'"results": [' +
							'{' +
							'"urls": {' +
							'"small": "https://images.unsplash.com/test-image.jpg"' +
							'}' +
							'}' +
							']' +
							'}'
			);

			return response;
		}
	}


	@IsTest
	static void testUpdateItemImage() {

		Item__c item = new Item__c(
				Name = 'iMac',
				Family__c = 'Laptop',
				Type__c = 'Electronic',
				Price__c = 1500,
				AvailableQuantity__c = 5
		);

		insert item;


		Test.setMock(
						HttpCalloutMock.class,
				new UnsplashMock()
		);


		Test.startTest();

		ItemImageController.updateItemImage(
				item.Id
		);

		Test.stopTest();


		Item__c updatedItem = [
				SELECT Image__c
				FROM Item__c
				WHERE Id = :item.Id
		];


		System.assertEquals(
				'https://images.unsplash.com/test-image.jpg',
				updatedItem.Image__c
		);
	}
}