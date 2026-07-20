@IsTest
private class CheckoutControllerTest {

	@TestSetup
	static void setupData() {

		Account acc = new Account(
				Name = 'Test Account'
		);
		insert acc;


		Item__c item = new Item__c(
				Name = 'Test Laptop',
				Description__c = 'Test item',
				Family__c = 'Laptop',
				Type__c = 'Electronic',
				Price__c = 1000,
				AvailableQuantity__c = 5,
				Image__c = 'https://example.com/image.jpg'
		);
		insert item;
	}


	@IsTest
	static void testCheckoutCreatesPurchase() {

		Account acc = [
				SELECT Id
				FROM Account
				LIMIT 1
		];

		Item__c item = [
				SELECT Id, AvailableQuantity__c
				FROM Item__c
				LIMIT 1
		];


		CheckoutController.CartItemWrapper wrapper =
				new CheckoutController.CartItemWrapper();

		wrapper.itemId = item.Id;
		wrapper.amount = 2;


		List<CheckoutController.CartItemWrapper> cart =
				new List<CheckoutController.CartItemWrapper>();

		cart.add(wrapper);


		Test.startTest();

		Id purchaseId = CheckoutController.checkout(
				acc.Id,
				cart
		);

		Test.stopTest();


		Purchase__c purchase = [
				SELECT Id, ClientId__c
				FROM Purchase__c
				WHERE Id = :purchaseId
		];


		System.assertEquals(
				acc.Id,
				purchase.ClientId__c
		);


		PurchaseLine__c line = [
				SELECT Amount__c, UnitCost__c, ItemId__c
				FROM PurchaseLine__c
				WHERE PurchaseId__c = :purchaseId
		];


		System.assertEquals(
				2,
				line.Amount__c
		);


		System.assertEquals(
				1000,
				line.UnitCost__c
		);


		Item__c updatedItem = [
				SELECT AvailableQuantity__c
				FROM Item__c
				WHERE Id = :item.Id
		];


		System.assertEquals(
				3,
				updatedItem.AvailableQuantity__c
		);
	}


	@IsTest
	static void testCheckoutFailsWhenNotEnoughQuantity() {

		Account acc = [
				SELECT Id
				FROM Account
				LIMIT 1
		];

		Item__c item = [
				SELECT Id
				FROM Item__c
				LIMIT 1
		];

		CheckoutController.CartItemWrapper wrapper =
				new CheckoutController.CartItemWrapper();

		wrapper.itemId = item.Id;
		wrapper.amount = 100;


		List<CheckoutController.CartItemWrapper> cart =
				new List<CheckoutController.CartItemWrapper>();

		cart.add(wrapper);


		Test.startTest();

		Boolean exceptionThrown = false;

		try {

			CheckoutController.checkout(
					acc.Id,
					cart
			);

		} catch (AuraHandledException e) {

			exceptionThrown = true;

		}

		Test.stopTest();


		System.assertEquals(
				true,
				exceptionThrown
		);
	}
}