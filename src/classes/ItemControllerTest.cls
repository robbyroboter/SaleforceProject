@IsTest
private class ItemControllerTest {

	@TestSetup
	static void setupData() {

		List<Item__c> items = new List<Item__c>();

		items.add(
				new Item__c(
						Name = 'iPhone',
						Family__c = 'Phone',
						Type__c = 'Electronic',
						Price__c = 1200,
						AvailableQuantity__c = 10
				)
		);

		items.add(
				new Item__c(
						Name = 'MacBook',
						Family__c = 'Laptop',
						Type__c = 'Electronic',
						Price__c = 2500,
						AvailableQuantity__c = 5
				)
		);

		items.add(
				new Item__c(
						Name = 'Office Chair',
						Family__c = 'Accessory',
						Type__c = 'Furniture',
						Price__c = 300,
						AvailableQuantity__c = 20
				)
		);

		insert items;
	}


	@IsTest
	static void testGetAllItems() {

		Test.startTest();

		List<Item__c> result =
				ItemController.getItems(
						'',
						'',
						''
				);

		Test.stopTest();


		System.assertEquals(
				3,
				result.size()
		);
	}


	@IsTest
	static void testFilterByFamily() {

		Test.startTest();

		List<Item__c> result =
				ItemController.getItems(
						'Laptop',
						'',
						''
				);

		Test.stopTest();


		System.assertEquals(
				1,
				result.size()
		);


		System.assertEquals(
				'MacBook',
				result[0].Name
		);
	}


	@IsTest
	static void testFilterByType() {

		Test.startTest();

		List<Item__c> result =
				ItemController.getItems(
						'',
						'Furniture',
						''
				);

		Test.stopTest();


		System.assertEquals(
				1,
				result.size()
		);


		System.assertEquals(
				'Office Chair',
				result[0].Name
		);
	}


	@IsTest
	static void testSearchByName() {

		Test.startTest();

		List<Item__c> result =
				ItemController.getItems(
						'',
						'',
						'Mac'
				);

		Test.stopTest();


		System.assertEquals(
				1,
				result.size()
		);


		System.assertEquals(
				'MacBook',
				result[0].Name
		);
	}
}