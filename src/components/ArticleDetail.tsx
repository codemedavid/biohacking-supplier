import { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { supabase } from '../lib/supabase';
import { ArrowLeft, Calendar, User } from 'lucide-react';

interface Article {
    id: string;
    title: string;
    content: string;
    cover_image: string | null;
    author: string;
    published_date: string;
}

export default function ArticleDetail() {
    const { id } = useParams<{ id: string }>();
    const navigate = useNavigate();
    const [article, setArticle] = useState<Article | null>(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        if (id) {
            fetchArticle(id);
        }
    }, [id]);

    const fetchArticle = async (articleId: string) => {
        try {
            setLoading(true);

            const { data, error } = await supabase
                .from('guide_topics')
                .select('*')
                .eq('id', articleId)
                .eq('is_enabled', true)
                .single();

            if (error) throw error;

            if (data) {
                setArticle(data);
            }
        } catch (error) {
            console.error('Error fetching article:', error);
        } finally {
            setLoading(false);
        }
    };

    if (loading) {
        return (
            <div className="min-h-screen bg-theme-bg flex items-center justify-center">
                <div className="animate-spin w-8 h-8 border-2 border-charcoal-700/50 border-t-transparent rounded-full" />
            </div>
        );
    }

    if (!article) {
        return (
            <div className="min-h-screen bg-theme-bg flex items-center justify-center">
                <div className="text-center">
                    <h2 className="text-2xl font-bold text-white mb-4">Article Not Found</h2>
                    <button
                        onClick={() => navigate('/peptalk')}
                        className="text-theme-accent hover:underline"
                    >
                        Back to Articles
                    </button>
                </div>
            </div>
        );
    }

    return (
        <div className="min-h-screen bg-theme-bg">
            {/* Header */}
            <div className="bg-charcoal-900/40 backdrop-blur-md border-b border-charcoal-700/50 sticky top-0 z-10 shadow-sm">
                <div className="container mx-auto px-4 py-4">
                    <button
                        onClick={() => navigate('/peptalk')}
                        className="flex items-center gap-2 text-charcoal-300 hover:text-white transition-colors group"
                    >
                        <ArrowLeft className="w-5 h-5 group-hover:-translate-x-1 transition-transform" />
                        <span className="font-medium">Back to Peptalk</span>
                    </button>
                </div>
            </div>

            {/* Hero Section with Cover Image */}
            {article.cover_image && (
                <div className="relative w-full h-64 md:h-96 bg-gray-200">
                    <img
                        src={article.cover_image}
                        alt={article.title}
                        className="w-full h-full object-cover"
                    />
                    <div className="absolute inset-0 bg-gradient-to-t from-black/50 to-transparent" />
                </div>
            )}

            {/* Article Content */}
            <div className="container mx-auto px-4 py-8 max-w-4xl">
                <article className="bg-charcoal-900/40 backdrop-blur-md rounded-2xl shadow-lg overflow-hidden">
                    {/* Article Header */}
                    <div className="p-8 md:p-12 border-b border-charcoal-700/50">
                        <h1 className="text-3xl md:text-4xl font-bold text-white mb-6 leading-tight">
                            {article.title}
                        </h1>

                        {/* Meta Information */}
                        <div className="flex flex-wrap items-center gap-4 text-sm text-charcoal-300">
                            <div className="flex items-center gap-2">
                                <User className="w-4 h-4 text-gold-500" />
                                <span>By {article.author}</span>
                            </div>
                            <div className="flex items-center gap-2">
                                <Calendar className="w-4 h-4 text-gold-500" />
                                <span>{new Date(article.published_date).toLocaleDateString('en-US', {
                                    year: 'numeric',
                                    month: 'long',
                                    day: 'numeric'
                                })}</span>
                            </div>
                        </div>
                    </div>

                    {/* Article Body */}
                    <div className="p-8 md:p-12">
                        <div className="prose prose-lg max-w-none">
                            <p className="text-charcoal-200 leading-relaxed whitespace-pre-line text-base md:text-lg">
                                {article.content}
                            </p>
                        </div>
                    </div>
                </article>

                {/* Back Button (Bottom) */}
                <div className="mt-8 text-center">
                    <div className="mt-8 text-center">
                        <button
                            onClick={() => navigate('/peptalk')}
                            className="inline-flex items-center gap-2 bg-charcoal-800 text-white px-6 py-3 rounded-lg font-medium hover:bg-navy-800 transition-colors shadow-md hover:shadow-lg"
                        >
                            <ArrowLeft className="w-4 h-4" />
                            Back to Peptalk
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
}
