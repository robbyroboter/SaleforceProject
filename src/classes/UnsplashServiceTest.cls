@IsTest
private class UnsplashServiceTest {

	private class UnsplashSuccessMock implements HttpCalloutMock {

		public HTTPResponse respond(HTTPRequest request) {

			HttpResponse response = new HttpResponse();

			response.setStatusCode(200);

			response.setBody(
							'{' +
							'"results": [' +
							'{' +
							'"urls": {' +
							'"small": "https://images.unsplash.com/test.jpg"' +
							'}' +
							'}' +
							']' +
							'}'
			);

			return response;
		}
	}


	private class UnsplashEmptyMock implements HttpCalloutMock {

		public HTTPResponse respond(HTTPRequest request) {

			HttpResponse response = new HttpResponse();

			response.setStatusCode(200);

			response.setBody(
					'{"results":[]}'
			);

			return response;
		}
	}


	@IsTest
	static void testGetImageUrlSuccess() {

		Test.setMock(
						HttpCalloutMock.class,
				new UnsplashSuccessMock()
		);


		Test.startTest();

		String imageUrl =
				UnsplashService.getImageUrl(
						'iMac'
				);

		Test.stopTest();


		System.assertEquals(
				'https://images.unsplash.com/test.jpg',
				imageUrl
		);
	}


	@IsTest
	static void testGetImageUrlNoResults() {

		Test.setMock(
						HttpCalloutMock.class,
				new UnsplashEmptyMock()
		);


		Test.startTest();

		String imageUrl =
				UnsplashService.getImageUrl(
						'Unknown'
				);

		Test.stopTest();


		System.assertEquals(
				null,
				imageUrl
		);
	}
}