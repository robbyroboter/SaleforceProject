public with sharing class UnsplashService {

	public static String getImageUrl(String query) {

		HttpRequest request = new HttpRequest();

		request.setEndpoint(
						'https://api.unsplash.com/search/photos?query='
						+ EncodingUtil.urlEncode(query, 'UTF-8'));
		request.setMethod('GET');
		request.setHeader(
				'Authorization',
				'Client-ID J0AoWvLbynP8Z3n0IvOT1ocRd-1vQxwtfo38plaof4M');

		Http http = new Http();
		HttpResponse response = http.send(request);

		if(response.getStatusCode() == 200) {
			Map<String,Object> result = (Map<String,Object>)
							JSON.deserializeUntyped(response.getBody());

			List<Object> results = (List<Object>)result.get('results');

			if(!results.isEmpty()) {
				Map<String,Object> first = (Map<String,Object>)results[0];
				Map<String,Object> urls = (Map<String,Object>)first.get('urls');

				return (String)urls.get('small');
			}
		}
		return null;
	}
}