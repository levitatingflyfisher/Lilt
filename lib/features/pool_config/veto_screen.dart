import 'package:flutter/material.dart';
import 'package:lilt/domain/models/name.dart';

class VetoScreen extends StatefulWidget {
  final List<Name> pool;

  const VetoScreen({super.key, required this.pool});

  @override
  State<VetoScreen> createState() => _VetoScreenState();
}

class _VetoScreenState extends State<VetoScreen> {
  late final List<Name> _remaining = List.of(widget.pool);
  final Set<String> _vetoed = {};
  int _index = 0;
  bool _popping = false;

  void _finish() {
    if (_popping) return;
    _popping = true;
    final kept = _remaining.where((n) => !_vetoed.contains(n.id)).toList();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pop(kept);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_index >= _remaining.length) {
      _finish();
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final name = _remaining[_index];
    final progress = (_index + 1) / _remaining.length;
    final removedCount = _vetoed.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Veto Pass'),
        actions: [
          TextButton(
            onPressed: _finish,
            child: const Text('Done'),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(value: progress),
          if (removedCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '$removedCount removed',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  name.display,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w300,
                      ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 0, 32, 48),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.close),
                    label: const Text('Remove'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          Theme.of(context).colorScheme.error,
                    ),
                    onPressed: () => setState(() {
                      _vetoed.add(name.id);
                      _index++;
                    }),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('Keep'),
                    onPressed: () => setState(() => _index++),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
