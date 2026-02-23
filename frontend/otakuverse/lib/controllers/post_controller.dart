import 'package:get/get.dart';
import 'package:otakuverse/models/post_model.dart';
import 'package:otakuverse/services/post_service.dart';

class PostsController extends GetxController {
  final PostsService _postsService = PostsService();

  // ============================================
  // STATE
  // ============================================
  final RxList<PostModel> posts = <PostModel>[].obs;
  final Rx<PostModel?> selectedPost = Rx<PostModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // ============================================
  // CRÉER UN POST
  // ============================================
  Future<bool> createPost({
    required String caption,
    required List<String> mediaUrls,
    String? location,
    bool allowComments = true,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _postsService.createPost(
      caption: caption,
      mediaUrls: mediaUrls,
      location: location,
      allowComments: allowComments,
    );

    isLoading.value = false;

    if (result['success'] != null) {
      posts.insert(0, result['success'] as PostModel);
      return true;
    }

    errorMessage.value = result['error'] ?? 'Erreur';
    return false;
  }

  // ============================================
  // CHARGER LES POSTS D'UN USER
  // ============================================
  Future<void> loadUserPosts(String userId) async {
    isLoading.value = true;

    final result = await _postsService.getPostsByUser(userId);

    isLoading.value = false;

    if (result['success'] != null) {
      posts.value = result['success'] as List<PostModel>;
    } else {
      errorMessage.value = result['error'] ?? 'Erreur';
    }
  }

  // ============================================
  // SUPPRIMER UN POST
  // ============================================
  Future<bool> deletePost(String postId) async {
    final result = await _postsService.deletePost(postId);

    if (result['success'] == true) {
      posts.removeWhere((p) => p.id == postId);
      return true;
    }

    errorMessage.value = result['error'] ?? 'Erreur';
    return false;
  }

  // ============================================
  // ÉPINGLER UN POST
  // ============================================
  Future<void> pinPost(String postId) async {
    final result = await _postsService.pinPost(postId);

    if (result['success'] != null) {
      final index = posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        posts[index] = posts[index].copyWith(isPinned: result['success']);
        posts.refresh();
      }
    }
  }

  // ============================================
  // LIKER UN POST (optimistic update)
  // ============================================
  void likePost(String postId) {
    final index = posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      posts[index] = posts[index].copyWith(
        likesCount: posts[index].likesCount + 1,
      );
      posts.refresh();
    }
  }
}