import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otakuverse/core/constants/colors.dart';
import 'package:otakuverse/models/profile_model.dart';
import 'package:otakuverse/models/post_model.dart';
import 'package:otakuverse/services/post_service.dart';
import 'package:otakuverse/services/profile_service.dart';
import 'package:otakuverse/services/storage_service.dart';
import 'package:otakuverse/services/auth_service.dart';
import 'package:otakuverse/screens/profile/edit_profile_screen.dart';
import 'package:otakuverse/screens/auth/login_screen.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;
  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  ProfileModel? _profile;
  List<PostModel> _posts = [];
  List<PostModel> _likedPosts = [];
  bool _isLoading = true;
  bool _isMe = false;
  bool _isFollowing = false;
  String? _currentUserId;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ============================================
  // CHARGEMENT DES DONNÉES
  // ============================================
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final userData = await StorageService().getUserData();
      _currentUserId = userData?['id'];

      if (_currentUserId == null) {
        if (mounted) Get.offAll(() => const SignInScreen());
        return;
      }

      final targetId = widget.userId ?? _currentUserId;
      _isMe = widget.userId == null || widget.userId == _currentUserId;

      final profileResult = _isMe
          ? await ProfileService().getMyProfile()
          : await ProfileService().getProfile(targetId!);

      final postsResult = await PostsService().getPostsByUser(targetId!);

      if (_isMe) {
      final likedResult = await PostsService().getLikedPosts(_currentUserId!);
      if (likedResult['success'] != null) {
        _likedPosts = likedResult['success'] as List<PostModel>;
      }
    }

      if (mounted) {
        setState(() {
          if (profileResult['success'] != null) {
            _profile = profileResult['success'] as ProfileModel;
          }
          if (postsResult['success'] != null) {
            _posts = postsResult['success'] as List<PostModel>;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ============================================
  // DÉCONNEXION
  // ============================================
  Future<void> _logout() async {
    await AuthService().signout();
    if (mounted) Get.offAll(() => const SignInScreen());
  }

  // ============================================
  // MENU PARAMÈTRES
  // ============================================
  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkGray,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.mediumGray,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          _settingsItem(Icons.edit_outlined, 'Modifier le profil', () {
            Navigator.pop(context);
            Navigator.push(context,
              MaterialPageRoute(builder: (_) => EditProfileScreen(profile: _profile!))
            ).then((_) => _loadData());
          }),
          _settingsItem(Icons.lock_outline, 'Changer le mot de passe', () {
            Navigator.pop(context);
            // TODO: NavigateToChangePasswordScreen
          }),
          _settingsItem(Icons.notifications_outlined, 'Notifications', () {
            Navigator.pop(context);
            // TODO: NavigateToNotificationsScreen
          }),
          _settingsItem(Icons.privacy_tip_outlined, 'Confidentialité', () {
            Navigator.pop(context);
            // TODO: NavigateToPrivacyScreen
          }),
          _settingsItem(Icons.shield_outlined, 'Sécurité', () {
            Navigator.pop(context);
            // TODO: NavigateToSecurityScreen
          }),
          _settingsItem(Icons.help_outline, 'Aide & Support', () {
            Navigator.pop(context);
            // TODO: NavigateToHelpScreen
          }),
          const Divider(color: AppColors.mediumGray, height: 1),
          _settingsItem(
            Icons.logout,
            'Se déconnecter',
            () {
              Navigator.pop(context);
              _showLogoutConfirmation();
            },
            color: AppColors.crimsonRed,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _settingsItem(IconData icon, String label, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.pureWhite, size: 22),
      title: Text(
        label,
        style: GoogleFonts.inter(
          color: color ?? AppColors.pureWhite,
          fontSize: 15,
        ),
      ),
      trailing: color == null
          ? const Icon(Icons.arrow_forward_ios, color: AppColors.mediumGray, size: 14)
          : null,
      onTap: onTap,
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkGray,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Se déconnecter ?',
          style: GoogleFonts.poppins(color: AppColors.pureWhite, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Tu seras redirigé vers la page de connexion.',
          style: GoogleFonts.inter(color: AppColors.mediumGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: GoogleFonts.inter(color: AppColors.mediumGray)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.crimsonRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Déconnecter', style: GoogleFonts.inter(color: AppColors.pureWhite)),
          ),
        ],
      ),
    );
  }

  

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.deepBlack,
        body: Center(child: CircularProgressIndicator(color: AppColors.crimsonRed)),
      );
    }

    if (_profile == null) {
      return Scaffold(
        backgroundColor: AppColors.deepBlack,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_off_outlined, color: AppColors.mediumGray, size: 48),
              const SizedBox(height: 16),
              Text('Profil introuvable',
                style: GoogleFonts.poppins(color: AppColors.pureWhite, fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _loadData,
                child: Text('Réessayer', style: GoogleFonts.inter(color: AppColors.crimsonRed)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      body: RefreshIndicator(
        color: AppColors.crimsonRed,
        backgroundColor: AppColors.darkGray,
        onRefresh: _loadData,
        child: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            _buildSliverAppBar(),
            SliverToBoxAdapter(child: _buildProfileHeader()),
            SliverToBoxAdapter(child: _buildStats()),
            SliverToBoxAdapter(child: _buildBio()),
            if (_profile!.favoriteGenres.isNotEmpty)
              SliverToBoxAdapter(child: _buildGenres()),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.crimsonRed,
                  indicatorWeight: 3,
                  labelColor: AppColors.crimsonRed,
                  unselectedLabelColor: AppColors.mediumGray,
                  labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
                  unselectedLabelStyle: GoogleFonts.inter(fontSize: 13),
                  tabs: const [
                    Tab(text: 'Posts'),
                    Tab(text: 'À propos'),
                    Tab(text: 'Animés'),
                    Tab(text: 'Likes'),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildPostsTab(),
              _buildAboutTab(),
              _buildAnimesTab(),
              _buildLikesTab(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // SLIVER APP BAR
  // ============================================
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      backgroundColor: AppColors.deepBlack,
      automaticallyImplyLeading: false, // 👈 pas de bouton retour
      pinned: true,
      elevation: 0,
      title: Text(
        _profile!.displayNameOrUsername,
        style: GoogleFonts.poppins(color: AppColors.pureWhite, fontWeight: FontWeight.w600),
      ),
      actions: [
        // Bouton paramètres — seulement sur son propre profil
        if (_isMe)
          IconButton(
            icon: const Icon(Icons.menu, color: AppColors.pureWhite),
            onPressed: _showSettingsSheet,
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Bannière
            _profile!.hasBanner
                ? Image.network(_profile!.bannerUrl!, fit: BoxFit.cover)
                : Container(decoration: const BoxDecoration(gradient: AppColors.primaryGradient)),

            // Dégradé bas
            DecoratedBox(decoration: BoxDecoration(gradient: AppColors.overlayGradient)),

            // Avatar + bouton action superposés
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Avatar
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.crimsonRed, width: 3),
                        ),
                        child: CircleAvatar(
                          radius: 36,
                          backgroundColor: AppColors.darkGray,
                          backgroundImage: _profile!.hasAvatar
                              ? NetworkImage(_profile!.avatarUrl!)
                              : null,
                          child: !_profile!.hasAvatar
                              ? const Icon(Icons.person, color: AppColors.pureWhite, size: 32)
                              : null,
                        ),
                      ),
                      // Bouton modifier l'avatar si c'est mon profil
                      if (_isMe)
                        Positioned(
                          bottom: 0, right: 0,
                          child: GestureDetector(
                            onTap: () async {
                              await Navigator.push(context,
                                MaterialPageRoute(builder: (_) => EditProfileScreen(profile: _profile!)));
                              _loadData();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.crimsonRed,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, color: AppColors.pureWhite, size: 12),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const Spacer(),

                  // Bouton Suivre (autre profil) ou Modifier (mon profil)
                  if (_isMe)
                    GestureDetector(
                      onTap: () async {
                        await Navigator.push(context,
                          MaterialPageRoute(builder: (_) => EditProfileScreen(profile: _profile!)));
                        _loadData();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.pureWhite, width: 2),
                        ),
                        child: Text(
                          'Modifier',
                          style: GoogleFonts.inter(
                            color: AppColors.pureWhite,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () => setState(() => _isFollowing = !_isFollowing),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: _isFollowing ? Colors.transparent : AppColors.crimsonRed,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.crimsonRed, width: 2),
                          boxShadow: _isFollowing ? [] : [
                            BoxShadow(color: AppColors.crimsonShadow, blurRadius: 12, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Text(
                          _isFollowing ? 'Abonné' : 'Suivre',
                          style: GoogleFonts.inter(
                            color: AppColors.pureWhite,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // HEADER (nom + badges)
  // ============================================
  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _profile!.displayNameOrUsername,
                      style: GoogleFonts.poppins(
                        color: AppColors.pureWhite,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_profile!.isVerified) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.verified, color: AppColors.crimsonRed, size: 20),
                    ],
                    if (_profile!.isPrivate) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.lock_outline, color: AppColors.mediumGray, size: 16),
                    ],
                  ],
                ),
                if (_profile!.location != null || _profile!.website != null)
                  const SizedBox(height: 6),
                Row(
                  children: [
                    if (_profile!.location != null) ...[
                      const Icon(Icons.location_on_outlined, color: AppColors.mediumGray, size: 14),
                      const SizedBox(width: 4),
                      Text(_profile!.location!,
                        style: GoogleFonts.inter(color: AppColors.mediumGray, fontSize: 13)),
                      const SizedBox(width: 12),
                    ],
                    if (_profile!.website != null) ...[
                      const Icon(Icons.link, color: AppColors.crimsonRed, size: 14),
                      const SizedBox(width: 4),
                      Text(_profile!.website!,
                        style: GoogleFonts.inter(
                          color: AppColors.crimsonRed, fontSize: 13,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.crimsonRed,
                        )),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // STATS
  // ============================================
  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          const Icon(Icons.people_outline, color: AppColors.mediumGray, size: 16),
          const SizedBox(width: 6),
          RichText(
            text: TextSpan(children: [
              TextSpan(
                text: '${_profile!.followersCount}',
                style: GoogleFonts.inter(color: AppColors.pureWhite, fontWeight: FontWeight.w700, fontSize: 14),
              ),
              TextSpan(
                text: ' Abonnés',
                style: GoogleFonts.inter(color: AppColors.mediumGray, fontSize: 14),
              ),
            ]),
          ),
          const SizedBox(width: 8),
          const Text('•', style: TextStyle(color: AppColors.successGreen, fontSize: 16)),
          const SizedBox(width: 8),
          RichText(
            text: TextSpan(children: [
              TextSpan(
                text: '${_profile!.postsCount}',
                style: GoogleFonts.inter(color: AppColors.pureWhite, fontWeight: FontWeight.w700, fontSize: 14),
              ),
              TextSpan(
                text: ' Posts',
                style: GoogleFonts.inter(color: AppColors.mediumGray, fontSize: 14),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  // ============================================
  // BIO
  // ============================================
  Widget _buildBio() {
    if (!_profile!.hasBio) return const SizedBox(height: 12);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Text(
        _profile!.bio!,
        style: GoogleFonts.inter(color: AppColors.lightGray, fontSize: 14, height: 1.5),
      ),
    );
  }

  // ============================================
  // GENRES
  // ============================================
  Widget _buildGenres() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Wrap(
        spacing: 8, runSpacing: 8,
        children: _profile!.favoriteGenres.map((genre) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.crimsonWithOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.crimsonWithOpacity(0.4)),
            ),
            child: Text('#$genre',
              style: GoogleFonts.inter(color: AppColors.lightCrimson, fontSize: 12, fontWeight: FontWeight.w500)),
          );
        }).toList(),
      ),
    );
  }

  // ============================================
  // TAB : POSTS
  // ============================================
  Widget _buildPostsTab() {
    return ListView(
      padding: const EdgeInsets.only(top: 8),
      children: [
        if (_isMe) _buildCreatePostBar(),
        if (_posts.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 48),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.post_add, color: AppColors.mediumGray, size: 48),
                  const SizedBox(height: 12),
                  Text('Aucun post pour le moment',
                    style: GoogleFonts.inter(color: AppColors.mediumGray)),
                ],
              ),
            ),
          )
        else
          ..._posts.map((post) => _buildPostCard(post)),
      ],
    );
  }

  Widget _buildCreatePostBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mediumGray.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.mediumGray,
            backgroundImage: _profile!.hasAvatar ? NetworkImage(_profile!.avatarUrl!) : null,
            child: !_profile!.hasAvatar
                ? const Icon(Icons.person, color: AppColors.pureWhite, size: 18)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text('Commencer une discussion...',
              style: GoogleFonts.inter(color: AppColors.mediumGray, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(PostModel post) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mediumGray.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.mediumGray,
                  backgroundImage: _profile!.hasAvatar ? NetworkImage(_profile!.avatarUrl!) : null,
                  child: !_profile!.hasAvatar
                      ? const Icon(Icons.person, color: AppColors.pureWhite, size: 16)
                      : null,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_profile!.displayNameOrUsername,
                      style: GoogleFonts.inter(color: AppColors.pureWhite, fontWeight: FontWeight.w600, fontSize: 13)),
                    Text(_formatDate(post.createdAt),
                      style: GoogleFonts.inter(color: AppColors.mediumGray, fontSize: 11)),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.more_horiz, color: AppColors.mediumGray),
              ],
            ),
          ),

          // Caption
          if (post.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Text(post.caption,
                style: GoogleFonts.inter(color: AppColors.pureWhite, fontSize: 14, height: 1.5)),
            ),

          // Image
          if (post.mediaUrls.isNotEmpty)
            ClipRRect(
              child: Image.network(post.mediaUrls.first,
                width: double.infinity, height: 200, fit: BoxFit.cover),
            ),

          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _actionButton(Icons.favorite_border, '${post.likesCount}', AppColors.crimsonRed),
                const SizedBox(width: 16),
                _actionButton(Icons.chat_bubble_outline, '${post.commentsCount}', AppColors.mediumGray),
                const Spacer(),
                _actionButton(Icons.share_outlined, 'Partager', AppColors.mediumGray),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.inter(color: AppColors.mediumGray, fontSize: 13)),
      ],
    );
  }

  // ============================================
  // TAB : À PROPOS
  // ============================================
  Widget _buildAboutTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _aboutSection('Informations', [
          if (_profile!.location != null)
            _aboutItem(Icons.location_on_outlined, 'Localisation', _profile!.location!),
          if (_profile!.website != null)
            _aboutItem(Icons.link, 'Site web', _profile!.website!, isLink: true),
          if (_profile!.birthDate != null)
            _aboutItem(Icons.cake_outlined, 'Date de naissance', _profile!.birthDate!),
          if (_profile!.gender != null)
            _aboutItem(Icons.person_outline, 'Genre', _genderLabel(_profile!.gender!)),
        ]),
        const SizedBox(height: 16),
        _aboutSection('Statistiques', [
          _aboutItem(Icons.article_outlined, 'Posts', '${_profile!.postsCount}'),
          _aboutItem(Icons.people_outline, 'Abonnés', '${_profile!.followersCount}'),
          _aboutItem(Icons.person_add_outlined, 'Abonnements', '${_profile!.followingCount}'),
        ]),
      ],
    );
  }

  Widget _aboutSection(String title, List<Widget> items) {
    if (items.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
          style: GoogleFonts.poppins(color: AppColors.pureWhite, fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.darkGray,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.mediumGray.withOpacity(0.3)),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _aboutItem(IconData icon, String label, String value, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.crimsonRed, size: 20),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.inter(color: AppColors.mediumGray, fontSize: 14)),
          const Spacer(),
          Text(value,
            style: GoogleFonts.inter(
              color: isLink ? AppColors.crimsonRed : AppColors.pureWhite,
              fontSize: 14, fontWeight: FontWeight.w500,
              decoration: isLink ? TextDecoration.underline : null,
              decorationColor: AppColors.crimsonRed,
            )),
        ],
      ),
    );
  }

  // ============================================
  // TAB : ANIMÉS
  // ============================================
  Widget _buildAnimesTab() {
    final hasContent = _profile!.favoriteAnime.isNotEmpty || _profile!.favoriteManga.isNotEmpty;

    if (!hasContent) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border, color: AppColors.mediumGray, size: 48),
            const SizedBox(height: 12),
            Text('Aucun animé/manga favori',
              style: GoogleFonts.inter(color: AppColors.mediumGray)),
            if (_isMe) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  await Navigator.push(context,
                    MaterialPageRoute(builder: (_) => EditProfileScreen(profile: _profile!)));
                  _loadData();
                },
                child: Text('Ajouter des favoris',
                  style: GoogleFonts.inter(color: AppColors.crimsonRed, fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_profile!.favoriteAnime.isNotEmpty) ...[
          Text('Animés favoris',
            style: GoogleFonts.poppins(color: AppColors.pureWhite, fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8,
            children: _profile!.favoriteAnime.map((a) => _favoriteChip(a)).toList()),
          const SizedBox(height: 20),
        ],
        if (_profile!.favoriteManga.isNotEmpty) ...[
          Text('Mangas favoris',
            style: GoogleFonts.poppins(color: AppColors.pureWhite, fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8,
            children: _profile!.favoriteManga.map((m) => _favoriteChip(m)).toList()),
        ],
      ],
    );
  }

  Widget _favoriteChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.crimsonWithOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.crimsonWithOpacity(0.4)),
      ),
      child: Text(label,
        style: GoogleFonts.inter(color: AppColors.lightCrimson, fontSize: 13, fontWeight: FontWeight.w500)),
    );
  }

  // ============================================
  // Like Posts
  // ============================================
  Widget _buildLikesTab() {
    if (_likedPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border, color: AppColors.mediumGray, size: 48),
            const SizedBox(height: 12),
            Text('Aucun post liké',
              style: GoogleFonts.inter(color: AppColors.mediumGray)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: _likedPosts.length,
      itemBuilder: (context, index) {
        final post = _likedPosts[index];
        return Stack(
          fit: StackFit.expand,
          children: [
            post.mediaUrls.isNotEmpty
                ? Image.network(post.mediaUrls.first, fit: BoxFit.cover)
                : Container(
                    color: AppColors.darkGray,
                    padding: const EdgeInsets.all(8),
                    child: Text(post.caption,
                      style: GoogleFonts.inter(color: AppColors.pureWhite, fontSize: 11),
                      maxLines: 4, overflow: TextOverflow.ellipsis),
                  ),
            DecoratedBox(decoration: BoxDecoration(gradient: AppColors.overlayGradient)),
            const Positioned(
              bottom: 6, left: 6,
              child: Icon(Icons.favorite, color: AppColors.crimsonRed, size: 14),
            ),
          ],
        );
      },
    );
  }

  // ============================================
  // HELPERS
  // ============================================
  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
    if (diff.inDays < 7) return 'il y a ${diff.inDays} j';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _genderLabel(String gender) {
    const labels = {
      'male': 'Homme', 'female': 'Femme',
      'other': 'Autre', 'prefer_not_to_say': 'Préfère ne pas dire',
    };
    return labels[gender] ?? gender;
  }
}

// ============================================
// TAB BAR DELEGATE
// ============================================
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _TabBarDelegate(this.tabBar);

  @override
  Widget build(_, __, ___) => Container(color: AppColors.deepBlack, child: tabBar);

  @override double get maxExtent => tabBar.preferredSize.height;
  @override double get minExtent => tabBar.preferredSize.height;
  @override bool shouldRebuild(_) => false;
}