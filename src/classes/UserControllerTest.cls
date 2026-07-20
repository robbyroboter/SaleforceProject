@IsTest
private class UserControllerTest {

	@IsTest
	static void testCurrentUserIsManager() {

		Test.startTest();

		Boolean result =
				UserController.isCurrentUserManager();

		Test.stopTest();


		System.assertNotEquals(
				null,
				result
		);
	}
}