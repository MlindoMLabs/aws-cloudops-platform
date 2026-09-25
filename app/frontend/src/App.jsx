import React, { useState, useEffect } from 'react';
import { fetchTasks, createTask, deleteTask } from './services/api';

export default function App() {
  const [tasks, setTasks] = useState([]);
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(true);

  const loadTasks = async () => {
    try {
      setLoading(true);
      const res = await fetchTasks();
      setTasks(res.data || []);
      setError(null);
    } catch (err) {
      setError('Unable to load tasks. Ensure backend service is reachable.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadTasks();
  }, []);

  const handleCreate = async (e) => {
    e.preventDefault();
    if (!title.trim()) return;

    try {
      await createTask({ title, description });
      setTitle('');
      setDescription('');
      await loadTasks();
    } catch (err) {
      setError('Failed to save task.');
    }
  };

  const handleDelete = async (id) => {
    try {
      await deleteTask(id);
      await loadTasks();
    } catch (err) {
      setError('Failed to delete task.');
    }
  };

  return (
    <div style={{ maxWidth: '800px', margin: '40px auto', padding: '0 20px' }}>
      <header style={{ borderBottom: '1px solid #334155', paddingBottom: '20px', marginBottom: '30px' }}>
        <h1 style={{ color: '#38bdf8', margin: 0 }}>AWS CloudOps Platform</h1>
        <p style={{ color: '#94a3b8', margin: '8px 0 0 0' }}>Multi-Tier Cloud Application Dashboard</p>
      </header>

      {error && (
        <div style={{ background: '#7f1d1d', color: '#fca5a5', padding: '12px 16px', borderRadius: '6px', marginBottom: '20px' }}>
          {error}
        </div>
      )}

      <form onSubmit={handleCreate} style={{ background: '#1e293b', padding: '20px', borderRadius: '8px', marginBottom: '30px' }}>
        <h3 style={{ marginTop: 0 }}>Add New Task</h3>
        <div style={{ marginBottom: '15px' }}>
          <input
            type="text"
            placeholder="Task Title"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            style={{ width: '100%', padding: '10px', borderRadius: '4px', border: '1px solid #475569', background: '#0f172a', color: '#fff', boxSizing: 'border-box' }}
          />
        </div>
        <div style={{ marginBottom: '15px' }}>
          <textarea
            placeholder="Task Description"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            style={{ width: '100%', padding: '10px', borderRadius: '4px', border: '1px solid #475569', background: '#0f172a', color: '#fff', boxSizing: 'border-box', height: '80px' }}
          />
        </div>
        <button type="submit" style={{ background: '#0284c7', color: '#fff', border: 'none', padding: '10px 20px', borderRadius: '4px', cursor: 'pointer', fontWeight: 'bold' }}>
          Create Task
        </button>
      </form>

      <section>
        <h2>System Tasks</h2>
        {loading ? (
          <p>Loading active tasks...</p>
        ) : tasks.length === 0 ? (
          <p style={{ color: '#64748b' }}>No tasks found in database.</p>
        ) : (
          <div style={{ display: 'grid', gap: '15px' }}>
            {tasks.map((task) => (
              <div key={task.id} style={{ background: '#1e293b', padding: '16px', borderRadius: '6px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <div>
                  <h4 style={{ margin: '0 0 6px 0', color: '#f1f5f9' }}>{task.title}</h4>
                  <p style={{ margin: 0, color: '#94a3b8', fontSize: '14px' }}>{task.description}</p>
                </div>
                <button onClick={() => handleDelete(task.id)} style={{ background: '#dc2626', color: '#fff', border: 'none', padding: '6px 12px', borderRadius: '4px', cursor: 'pointer' }}>
                  Delete
                </button>
              </div>
            ))}
          </div>
        )}
      </section>
    </div>
  );
}
