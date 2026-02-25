/**
 * Tutor page — AI tutor chat interface for exercise help.
 */

import { useState, useRef, useEffect } from 'react';
import { useMutation } from '@tanstack/react-query';
import { useTodayExercises } from '@/hooks/useExercises';
import { askTutor } from '@/services/tutorService';
import type { TutorResponse } from '@/types';
import Layout from '@/components/Layout';
import MarkdownViewer from '@/components/MarkdownViewer';
import styles from './TutorPage.module.css';

interface ChatMessage {
  id: number;
  role: 'user' | 'tutor';
  content: string;
  timestamp: Date;
}

export default function TutorPage(): JSX.Element {
  const { data: todayData } = useTodayExercises();
  const exercises = todayData?.exercises;

  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [input, setInput] = useState('');
  const [selectedExercise, setSelectedExercise] = useState<string>('');
  const [messageCounter, setMessageCounter] = useState(0);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const tutorMutation = useMutation<TutorResponse, Error, { message: string; exerciseId?: string }>({
    mutationFn: ({ message, exerciseId }) =>
      askTutor({
        message,
        exerciseId: exerciseId || null,
        code: null,
      }),
    onSuccess: (data) => {
      setMessageCounter((c) => c + 1);
      const tutorMsg: ChatMessage = {
        id: messageCounter + 1,
        role: 'tutor',
        content: data.reply,
        timestamp: new Date(),
      };
      setMessages((prev) => [...prev, tutorMsg]);
    },
    onError: (error) => {
      const errorMsg: ChatMessage = {
        id: messageCounter + 1,
        role: 'tutor',
        content: `Помилка: ${error.message}`,
        timestamp: new Date(),
      };
      setMessages((prev) => [...prev, errorMsg]);
      setMessageCounter((c) => c + 1);
    },
  });

  // Auto-scroll to bottom on new messages
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const handleSend = (): void => {
    const trimmed = input.trim();
    if (!trimmed) return;

    const userMsg: ChatMessage = {
      id: messageCounter,
      role: 'user',
      content: trimmed,
      timestamp: new Date(),
    };

    setMessages((prev) => [...prev, userMsg]);
    setMessageCounter((c) => c + 1);
    setInput('');

    tutorMutation.mutate({
      message: trimmed,
      exerciseId: selectedExercise || undefined,
    });
  };

  const handleKeyDown = (e: React.KeyboardEvent): void => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSend();
    }
  };

  return (
    <Layout>
      <div className={styles.page}>
        <div className={styles.header}>
          <h1 className={styles.heading}>AI Тьютор</h1>
          <p className={styles.subtitle}>
            Задай питання про вправу або концепцію C/Shell
          </p>
        </div>

        {/* Exercise context selector */}
        <div className={styles.contextBar}>
          <label className={styles.contextLabel} htmlFor="exerciseContext">
            Контекст вправи:
          </label>
          <select
            id="exerciseContext"
            className={styles.contextSelect}
            value={selectedExercise}
            onChange={(e) => setSelectedExercise(e.target.value)}
          >
            <option value="">Без контексту</option>
            {exercises?.map((ex) => (
              <option key={ex.id} value={ex.id}>
                {ex.module.toUpperCase()} — {ex.title}
              </option>
            ))}
          </select>
        </div>

        {/* Chat messages */}
        <div className={styles.chatArea}>
          {messages.length === 0 && (
            <div className={styles.emptyChat}>
              <p className={styles.emptyText}>
                Привіт! Я твій AI-тьютор. Задавай питання про C, Shell, або вправи.
              </p>
              <p className={styles.emptyHint}>
                Я не даю готових відповідей, але допоможу зрозуміти концепцію.
              </p>
            </div>
          )}

          {messages.map((msg) => (
            <div
              key={msg.id}
              className={`${styles.message} ${msg.role === 'user' ? styles.messageUser : styles.messageTutor}`}
            >
              <div className={styles.messageHeader}>
                <span className={styles.messageRole}>
                  {msg.role === 'user' ? 'Ти' : 'Тьютор'}
                </span>
                <span className={styles.messageTime}>
                  {msg.timestamp.toLocaleTimeString('uk-UA', {
                    hour: '2-digit',
                    minute: '2-digit',
                  })}
                </span>
              </div>
              <div className={styles.messageContent}>
                {msg.role === 'tutor' ? (
                  <MarkdownViewer content={msg.content} />
                ) : (
                  <p>{msg.content}</p>
                )}
              </div>
            </div>
          ))}

          {tutorMutation.isPending && (
            <div className={`${styles.message} ${styles.messageTutor}`}>
              <div className={styles.messageHeader}>
                <span className={styles.messageRole}>Тьютор</span>
              </div>
              <div className={styles.typing}>
                <span className={styles.typingDot} />
                <span className={styles.typingDot} />
                <span className={styles.typingDot} />
              </div>
            </div>
          )}

          <div ref={messagesEndRef} />
        </div>

        {/* Input */}
        <div className={styles.inputArea}>
          <textarea
            className={styles.textarea}
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyDown={handleKeyDown}
            placeholder="Напиши питання..."
            rows={2}
            disabled={tutorMutation.isPending}
            aria-label="Повідомлення для тьютора"
          />
          <button
            className="btn btn-primary"
            onClick={handleSend}
            disabled={!input.trim() || tutorMutation.isPending}
            type="button"
          >
            Надіслати
          </button>
        </div>
      </div>
    </Layout>
  );
}
