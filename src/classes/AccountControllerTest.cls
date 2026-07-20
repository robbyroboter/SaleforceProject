@IsTest
private class AccountControllerTest {

	@TestSetup
	static void setupData() {

		Account acc = new Account(
				Name = 'Test Customer',
				AccountNumber = 'ACC-001',
				Industry = 'Technology'
		);

		insert acc;
	}


	@IsTest
	static void testGetAccountInfo() {

		Account acc = [
				SELECT Id
				FROM Account
				LIMIT 1
		];


		Test.startTest();

		Account result =
				AccountController.getAccountInfo(
						acc.Id
				);

		Test.stopTest();


		System.assertNotEquals(
				null,
				result
		);


		System.assertEquals(
				'Test Customer',
				result.Name
		);


		System.assertEquals(
				'ACC-001',
				result.AccountNumber
		);


		System.assertEquals(
				'Technology',
				result.Industry
		);
	}
}