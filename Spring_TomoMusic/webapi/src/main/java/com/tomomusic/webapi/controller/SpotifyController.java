package com.tomomusic.webapi.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/spotify")
public class SpotifyController {

    @Value("${spotify.client-id}")
    private String clientId;

    @Value("${spotify.client-secret}")
    private String clientSecret;

    private static final String TOKEN_URL = "https://accounts.spotify.com/api/token";
    private static final String API_BASE_URL = "https://api.spotify.com/v1/";
    private final String SPOTIFY_API_URL = "https://api.spotify.com/v1/recommendations";

    // 🎯 앨범 & 트랙 검색 API
    @GetMapping("/search")
    public ResponseEntity<Map<String, Object>> search(@RequestParam String query) {
        String accessToken = getAccessToken();
        return ResponseEntity.ok(fetchAlbumsAndTracks(query, accessToken));
    }

    // ✅ 앨범 & 트랙을 함께 검색하는 메서드
    private Map<String, Object> fetchAlbumsAndTracks(String query, String accessToken) {
        String url = API_BASE_URL + "search?q=" + query + "&type=album,track&limit=10";

        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + accessToken);

        HttpEntity<String> entity = new HttpEntity<>(headers);
        RestTemplate restTemplate = new RestTemplate();
        ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.GET, entity, String.class);

        return parseSpotifyResponse(response.getBody());
    }

    // ✅ JSON 응답을 Map으로 변환 (앨범 + 트랙 포함)
    private Map<String, Object> parseSpotifyResponse(String responseBody) {
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            JsonNode jsonResponse = objectMapper.readTree(responseBody);

            Map<String, Object> result = new HashMap<>();
            result.put("albums", jsonResponse.get("albums"));
            result.put("tracks", jsonResponse.get("tracks"));

            return result;
        } catch (Exception e) {
            throw new RuntimeException("Error parsing Spotify response", e);
        }
    }

    // ✅ Spotify Access Token 가져오는 메서드
    private String getAccessToken() {
        String credentials = clientId + ":" + clientSecret;
        String base64Credentials = new String(java.util.Base64.getEncoder().encode(credentials.getBytes()));

        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Basic " + base64Credentials);
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);

        HttpEntity<String> entity = new HttpEntity<>("grant_type=client_credentials", headers);

        RestTemplate restTemplate = new RestTemplate();
        ResponseEntity<String> response = restTemplate.exchange(TOKEN_URL, HttpMethod.POST, entity, String.class);

        return parseAccessToken(response.getBody());
    }

    private String parseAccessToken(String responseBody) {
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            JsonNode jsonResponse = objectMapper.readTree(responseBody);
            return jsonResponse.get("access_token").asText();
        } catch (Exception e) {
            throw new RuntimeException("Error parsing access token response", e);
        }
    }

    @GetMapping("/album/{id}")
    public ResponseEntity<String> getAlbumInfo(@PathVariable String id) {
        // Step 1: Get Access Token
        String accessToken = getAccessToken();

        // Step 2: Fetch Album Info using the access token
        String albumInfo = fetchAlbumInfo(id, accessToken);
        // System.out.println(albumInfo);
        return ResponseEntity.ok(albumInfo);
    }

    private String fetchAlbumInfo(String id, String accessToken) {
        String url = API_BASE_URL + "albums/" + id;

        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + accessToken);

        HttpEntity<String> entity = new HttpEntity<>(headers);

        RestTemplate restTemplate = new RestTemplate();
        ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.GET, entity, String.class);

        return response.getBody();
    }

    // ✅ 앨범 상세 정보를 가져오는 메서드
    private Map<String, Object> fetchAlbumDetails(String id, String accessToken) {
        String url = API_BASE_URL + "albums/" + id;

        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + accessToken);

        HttpEntity<String> entity = new HttpEntity<>(headers);
        RestTemplate restTemplate = new RestTemplate();
        ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.GET, entity, String.class);

        return parseAlbumDetailsResponse(response.getBody());
    }

    private Map<String, Object> parseAlbumDetailsResponse(String responseBody) {
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            JsonNode jsonResponse = objectMapper.readTree(responseBody);

            Map<String, Object> result = new HashMap<>();

            // 앨범 정보 추출
            result.put("id", jsonResponse.get("id").asText());
            result.put("name", jsonResponse.get("name").asText());
            result.put("release_date", jsonResponse.get("release_date").asText());
            result.put("images", jsonResponse.get("images"));

            // 앨범의 아티스트 정보 추출
            JsonNode artistsNode = jsonResponse.get("artists");
            result.put("artists", artistsNode);

            // 트랙 정보 추출 (앨범 내 트랙들)
            JsonNode tracksNode = jsonResponse.get("tracks").get("items");
            result.put("tracks", tracksNode);

            return result;
        } catch (Exception e) {
            throw new RuntimeException("Error parsing album details response", e);
        }
    }

    @GetMapping("/track/{id}")
    public ResponseEntity<Map<String, Object>> getAlbumByTrackId(@PathVariable String id) {
        // Step 1: Access Token 가져오기
        String accessToken = getAccessToken();

        // Step 2: 트랙 정보를 가져와서 포함된 앨범 정보 추출
        return ResponseEntity.ok(fetchAlbumFromTrack(id, accessToken));
    }

    // ✅ 트랙 ID를 이용하여 해당 앨범 정보를 가져오는 메서드
    private Map<String, Object> fetchAlbumFromTrack(String trackId, String accessToken) {
        String url = API_BASE_URL + "tracks/" + trackId;

        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + accessToken);

        HttpEntity<String> entity = new HttpEntity<>(headers);
        RestTemplate restTemplate = new RestTemplate();
        ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.GET, entity, String.class);

        return parseTrackResponse(response.getBody());
    }

    // ✅ 트랙 응답에서 앨범 정보를 추출하는 메서드
    private Map<String, Object> parseTrackResponse(String responseBody) {
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            JsonNode jsonResponse = objectMapper.readTree(responseBody);
            System.out.println(jsonResponse);

            // 트랙 응답에서 앨범 정보 추출
            JsonNode albumNode = jsonResponse.get("album");

            Map<String, Object> albumInfo = new HashMap<>();
            albumInfo.put("id", albumNode.get("id").asText());
            albumInfo.put("name", jsonResponse.get("name").asText());
            // albumInfo.put("release_date", albumNode.get("release_date").asText());
            albumInfo.put("images", albumNode.get("images"));
            albumInfo.put("artists", albumNode.get("artists"));

            return albumInfo;
        } catch (Exception e) {
            throw new RuntimeException("Error parsing track response", e);
        }
    }

    @GetMapping("/album/{id}/detail")
    public ResponseEntity<Map<String, Object>> getDetailedAlbumInfo(@PathVariable String id) {
        // Step 1: Access Token 가져오기
        String accessToken = getAccessToken();

        // Step 2: 새로운 방식으로 앨범 상세 정보 가져오기
        Map<String, Object> albumDetails = fetchDetailedAlbumInfo(id, accessToken);

        return ResponseEntity.ok(albumDetails);
    }

    private Map<String, Object> fetchDetailedAlbumInfo(String id, String accessToken) {
        String url = API_BASE_URL + "albums/" + id;

        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + accessToken);

        HttpEntity<String> entity = new HttpEntity<>(headers);
        RestTemplate restTemplate = new RestTemplate();
        ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.GET, entity, String.class);

        return parseDetailedAlbumResponse(response.getBody());
    }

    private Map<String, Object> parseDetailedAlbumResponse(String responseBody) {
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            JsonNode jsonResponse = objectMapper.readTree(responseBody);

            Map<String, Object> albumInfo = new HashMap<>();

            // 기본 앨범 정보
            albumInfo.put("id", jsonResponse.get("id").asText());
            albumInfo.put("name", jsonResponse.get("name").asText());
            albumInfo.put("release_date", jsonResponse.get("release_date").asText());

            // ✅ 첫 번째 이미지 URL만 저장
            JsonNode imagesNode = jsonResponse.get("images");
            if (imagesNode != null && imagesNode.isArray() && imagesNode.size() > 0) {
                albumInfo.put("image_url", imagesNode.get(0).get("url").asText());
            } else {
                albumInfo.put("image_url", null);
            }

            // ✅ 아티스트 정보 저장 (이름 리스트로 변환)o
            JsonNode artistsNode = jsonResponse.get("artists");
            List<String> artistNames = new ArrayList<>();
            if (artistsNode != null && artistsNode.isArray()) {
                for (JsonNode artist : artistsNode) {
                    artistNames.add(artist.get("name").asText());
                }
            }
            albumInfo.put("artists", artistNames);

            // ✅ 트랙 정보 
            JsonNode tracksNode = jsonResponse.get("tracks").get("items");
            List<Map<String, Object>> trackList = new ArrayList<>();
            if (tracksNode != null && tracksNode.isArray()) {
                for (JsonNode track : tracksNode) {
                    Map<String, Object> trackInfo = new HashMap<>();
                    trackInfo.put("id", track.get("id").asText());
                    trackInfo.put("name", track.get("name").asText());
                    trackList.add(trackInfo);
                }
            }
            albumInfo.put("tracks", trackList);

            return albumInfo;
        } catch (Exception e) {
            throw new RuntimeException("Error parsing detailed album response", e);
        }
    }

    @GetMapping("/searchByEmotion")
    public ResponseEntity<Map<String, Object>> searchByEmotion(@RequestParam String[] emotions) {
        String accessToken = getAccessToken();
        return ResponseEntity.ok(fetchTracksByEmotion(emotions, accessToken));
    }

    // ✅ 감정에 맞는 트랙을 검색하는 메서드
    private Map<String, Object> fetchTracksByEmotion(String[] emotions, String accessToken) {
        // 감정에 맞는 트랙을 검색하는 쿼리 문자열 구성
        String[] query = convertEmotionsToQueries(emotions);
        String url = API_BASE_URL + "search?q=" + String.join(",", query) + "&type=track&limit=2"; // 최대 2개의 트랙 추천

        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + accessToken);

        HttpEntity<String> entity = new HttpEntity<>(headers);
        RestTemplate restTemplate = new RestTemplate();
        ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.GET, entity, String.class);

        return parseSpotifyResponse(response.getBody());
    }

    // 감정 이모지를 텍스트로 변환하는 메서드
    private String[] convertEmotionsToQueries(String[] emotions) {
        Map<String, String> emotionMapping = new HashMap<>();
        emotionMapping.put("🙂", "neutral");
        emotionMapping.put("😊", "happy");
        emotionMapping.put("😎", "chill");
        emotionMapping.put("😢", "sad");
        emotionMapping.put("😜", "playful");
        emotionMapping.put("🥳", "celebration");
        emotionMapping.put("🤩", "excited");
        emotionMapping.put("😇", "innocent");
        emotionMapping.put("🤔", "thoughtful");
        emotionMapping.put("🤯", "mindblown");
        emotionMapping.put("😈", "mischievous");
        emotionMapping.put("😱", "scared");
        emotionMapping.put("😷", "sick");
        emotionMapping.put("😳", "embarrassed");
        emotionMapping.put("🥺", "pleading");
        emotionMapping.put("😴", "sleepy");
        emotionMapping.put("💪", "strong");
        emotionMapping.put("❤️", "love");
        emotionMapping.put("🔥", "passionate");
        emotionMapping.put("😂", "laughing");
        emotionMapping.put("😭", "crying");
        emotionMapping.put("🥶", "cold");
        emotionMapping.put("🤪", "silly");
        emotionMapping.put("😡", "angry");
        emotionMapping.put("💀", "dead");

        // 감정 이모지를 해당하는 텍스트로 변환
        return Arrays.stream(emotions)
                .map(emotion -> emotionMapping.getOrDefault(emotion, "mood"))
                .toArray(String[]::new);
    }

}