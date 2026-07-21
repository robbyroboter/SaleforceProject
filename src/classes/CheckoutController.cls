public with sharing class CheckoutController {

	@AuraEnabled
	public static Id checkout(
			Id accountId,
			List<CartItemWrapper> cartItems
			) {

		List<Id> itemIds = new List<Id>();

		for (CartItemWrapper item : cartItems) {
			itemIds.add(item.itemId);
		}

		List<Item__c> items = [
				SELECT Id,
						Name,
						Price__c,
						AvailableQuantity__c
				FROM Item__c
				WHERE Id IN :itemIds
				FOR UPDATE
		];


		Map<Id, Item__c> itemMap = new Map<Id, Item__c>();

		for (Item__c item : items) {
			itemMap.put(item.Id, item);
		}


		for (CartItemWrapper cartItem : cartItems) {

			Item__c item = itemMap.get(cartItem.itemId);

			if (item.AvailableQuantity__c < cartItem.amount) {

				throw new AuraHandledException(
								'Not enough quantity for ' + item.Name
				);

			}
		}


		Purchase__c purchase = new Purchase__c(
				ClientId__c = accountId
		);

		insert purchase;


		List<PurchaseLine__c> lines = new List<PurchaseLine__c>();

		List<Item__c> updateItems = new List<Item__c>();


		for (CartItemWrapper cartItem : cartItems) {

			Item__c item = itemMap.get(cartItem.itemId);

			lines.add(
					new PurchaseLine__c(
							PurchaseId__c = purchase.Id,
							ItemId__c = item.Id,
							Amount__c = cartItem.amount,
							UnitCost__c = item.Price__c
					)
			);


			item.AvailableQuantity__c -= cartItem.amount;
			updateItems.add(item);
		}


		update updateItems;

		insert lines;


		return purchase.Id;
	}


	public class CartItemWrapper {

		@AuraEnabled
		public Id itemId {get;set;}

		@AuraEnabled
		public Integer amount {get;set;}

	}
}