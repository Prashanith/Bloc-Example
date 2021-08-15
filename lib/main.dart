import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:postfetcher/BloC/post_event.dart';
import 'package:postfetcher/BloC/post_state.dart';
import 'package:postfetcher/BloC/post_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:postfetcher/post.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(  
        body:BlocProvider(
          create: (context) =>
          PostBloc(httpClient: http.Client())..add(PostFetched()),
          child: HomePage(),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();
  final _scrollThreshold = 200.0;
  PostBloc _postBloc;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _postBloc = BlocProvider.of<PostBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostBloc, PostState>(
    builder: (context,state){
        if (state is PostInitial) {
          return Center(
          child: CircularProgressIndicator(),
          );
        }
        if (state is PostFailure) {
          return Center(
          child: Text('failed to fetch posts'),
          );
        }
        if (state is PostSuccess) {
          if (state.posts.isEmpty) {
            return Center(
            child: Text('no posts'),);
          }
          return ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return index >= state.posts.length
            ? Center(child: CircularProgressIndicator(),):PostWidget(post: state.posts[index]);
            },
            itemCount: state.hasReachedMax
            ? state.posts.length
                : state.posts.length + 1,
            controller: _scrollController,
            );
        }
        else{
          return Center();
        }
        },
    );
}

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      _postBloc.add(PostFetched());
    }
  }
}

class PostWidget extends StatelessWidget {
  final Post post;

  const PostWidget({Key key, @required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(
        '${post.id}',
        style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.w700),
      ),
      title: Text(post.title,style: TextStyle(fontWeight: FontWeight.w900),),
      isThreeLine: true,
      subtitle: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 1,
            child:Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2,vertical: 0),
              child: FloatingActionButton(onPressed: null,child:Icon(Icons.edit,size:10,color: Colors.blue,),
              backgroundColor: Colors.white,elevation: 0,
              ),
            ),
          ),
          Expanded(
            flex: 9,
              child: Text(post.body,style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.w500),) ,
          ),
        ],
      ),
    );
  }
}
