/**
 * Markdown viewer — renders exercise content with code highlighting.
 */

import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';
import styles from './MarkdownViewer.module.css';

interface MarkdownViewerProps {
  content: string;
}

export default function MarkdownViewer({
  content,
}: MarkdownViewerProps): JSX.Element {
  return (
    <div className={styles.markdown}>
      <ReactMarkdown
        remarkPlugins={[remarkGfm]}
        components={{
          code({ className, children, ...props }) {
            const isInline = !className;
            if (isInline) {
              return (
                <code className={styles.inlineCode} {...props}>
                  {children}
                </code>
              );
            }
            return (
              <code className={`${styles.blockCode} ${className ?? ''}`} {...props}>
                {children}
              </code>
            );
          },
          pre({ children }) {
            return <pre className={styles.pre}>{children}</pre>;
          },
          a({ href, children }) {
            return (
              <a href={href} target="_blank" rel="noopener noreferrer">
                {children}
              </a>
            );
          },
        }}
      >
        {content}
      </ReactMarkdown>
    </div>
  );
}
