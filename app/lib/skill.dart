import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_first_project/navigation_bar.dart' as nav;

class Skill {
  final String name;
  final List<String> parts;
  final bool isCompleted;

  //constructor
  Skill({
    required this.name,
    this.parts = const [],
    this.isCompleted = false,
  });
}

List<String> skills = [];

class SkillTrainerApp extends StatelessWidget {
  const SkillTrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Skill Trainer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SkillInputPage(),
    );
  }
}

class SkillInputPage extends StatelessWidget {
  const SkillInputPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Skill Trainer',style: TextStyle(color: Colors.white, fontWeight:FontWeight.bold)),
        backgroundColor: Colors.blue,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu,color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: nav.NavigationBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Enter a Skill',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      // Add the new skill to the global list
                      skills.add(controller.text);
                      controller.clear(); // Clear the input field
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class SkillListPage extends StatelessWidget {
  const SkillListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skill Trainer',style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu,color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: nav.NavigationBar(),
      body: ListView.builder(
        padding: const EdgeInsets.all(20.0),
        itemCount: skills.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(
                skills[index],
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                // Navigate to the SkillDetailsPage and pass the selected skill
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SkillRoadmapPage(skill: skills[index]),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}


class SkillRoadmapPage extends StatelessWidget {
  final String skill;

  const SkillRoadmapPage({super.key, required this.skill});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Skill Trainer - $skill',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu,color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: nav.NavigationBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SkillOption(title: 'Part 1'),
              SkillOption(title: 'Part 2'),
              SkillOption(title: 'Part 3'),
              SkillOption(title: 'Quiz'),
            ],
          ),
        ),
      ),
    );
  }
}

class SkillOption extends StatelessWidget {
  final String title;

  const SkillOption({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
        ),
        onPressed: () {
          // Navigate to the SkillDetailsPage, passing the title (skill name) as an argument
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SkillRoadmapPage(skill: title), // Pass the title here
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Icon(Icons.check_box_outline_blank_rounded),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 18, color: Colors.black,fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
