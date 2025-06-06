import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:i/view/speak_page.dart';
import 'package:i/view_model/page_fonts/local_view_model.dart';
import 'package:i/view_model/tasks/task_view_model.dart';
import 'package:i/view_model/theme_view_model.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i/view_model/home/home_view_model.dart';
import 'package:i/service/user_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? _searchDebounce;
  final _controller = TextEditingController();
  final _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    Provider.of<TaskViewModel>(context, listen: false).loadTasks(userId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        print('Campo perdeu o foco');
      }
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeViewModel = Provider.of<HomeViewModel>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final String userName = userProvider.userName;
    final String userEmail = userProvider.userEmail;
    final theme = Provider.of<ThemeApp>(context);
    final FocusNode _searchFocusNode =
        FocusNode(skipTraversal: true, canRequestFocus: false);

    String selectedValue = 'OPEN';

    void _showThemeOption() {
      showMenu(
        context: context,
        position: RelativeRect.fromLTRB(100, 160, 0, 0),
        items: [
          PopupMenuItem(
            child: Text('Light', style: TextStyle(color: Colors.black)),
            value: 'Light',
          ),
          PopupMenuItem(
            child: Text('Dark', style: TextStyle(color: Colors.black)),
            value: 'Dark',
          ),
        ],
      ).then((value) {
        if (value != null) {
          theme.currentThemeName = value;
        }
      });
    }

    void _showOptionsMenu() {
      showMenu(
        context: context,
        position: RelativeRect.fromLTRB(100, 160, 0, 0),
        items: [
          PopupMenuItem(
            child: TodoListFont(text: 'OPEN', color: Colors.black),
            value: 'OPEN',
          ),
          PopupMenuItem(
            child: TodoListFont(text: 'LATE', color: Colors.black),
            value: 'LATE',
          ),
          PopupMenuItem(
            child: TodoListFont(text: 'CLOSED', color: Colors.black),
            value: 'CLOSED',
          ),
          PopupMenuItem(
            child: TodoListFont(text: 'PRIORITY', color: Colors.black),
            value: 'PRIORITY',
          ),
        ],
      ).then((value) {
        if (value != null) {
          setState(() {
            selectedValue = value;
          });
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Icon(
          Icons.grid_goldenratio_outlined,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("" + homeViewModel.titles[homeViewModel.currentIndex],
                      style: GoogleFonts.lato(
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      )),
                ],
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Container(
                width: double.maxFinite / 2,
                height: 50,
                decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.5),
                      width: 1,
                    )),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: MouseRegion(
                          cursor: SystemMouseCursors.basic,
                          child: TextField(
                            focusNode: _searchFocusNode,
                            showCursor: true,
                            cursorColor: Colors.blueGrey,
                            style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search',
                              hintStyle: const TextStyle(
                                color: Colors.transparent,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              hoverColor: Colors.transparent,
                              fillColor: Colors.transparent,
                              filled: true,
                            ),
                            onChanged: (value) {
                              print("Search query: $value");
                              _searchDebounce?.cancel();
                              _searchDebounce =
                                  Timer(const Duration(milliseconds: 300), () {
                                Provider.of<TaskViewModel>(context,
                                        listen: false)
                                    .searchTask(value);
                              });
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.filter_list,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        onPressed: _showOptionsMenu,
                      ),
                    ],
                  ),
                ),
              )),
          Expanded(
            child: IndexedStack(
              index: homeViewModel.currentIndex,
              children: homeViewModel.pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: homeViewModel.currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 3) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Theme.of(context).colorScheme.background,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (context) => const Padding(
                padding:
                    EdgeInsets.only(top: 16, left: 8, right: 8, bottom: 32),
                child: SpeakPage(),
              ),
            );
            return;
          }
          homeViewModel.setCurrentIndex(index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Tasks'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined), label: 'Calendar'),
          BottomNavigationBarItem(
              icon: Icon(Icons.insert_chart_outlined_rounded),
              label: 'Statistics'),
          BottomNavigationBarItem(
              icon: Icon(Icons.fiber_manual_record_outlined), label: 'AI'),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
              ),
              accountName: Text(
                userName,
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              accountEmail: Text(
                userEmail,
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                child:
                    Text(userName.isNotEmpty ? userName[0].toUpperCase() : '?'),
              ),
            ),
            ListTile(
              leading: Icon(Icons.info_outline,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              title: Text('About this app',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(height: 0),
            ListTile(
              title: Text('Theme',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface)),
              leading: Icon(
                theme.currentThemeName == 'Light'
                    ? Icons.light_mode
                    : Icons.nightlight_outlined,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              onTap: _showThemeOption,
            ),
            const Divider(height: 0),
            ListTile(
              leading: Icon(Icons.exit_to_app,
                  color: Theme.of(context).colorScheme.error),
              title: Text('Exit',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface)),
              onTap: () async {
                await Provider.of<UserProvider>(context, listen: false)
                    .clearUser();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}
