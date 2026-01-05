import React, { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import ProblemSolvingLessonForm from "./ProblemSolvingLessonForm";
import { problemSolvingLessonService } from "../../../services/Gemified_Knowledge_Builder/problemSolvingLessonService.js";

const emptyTip = (n) => ({ tip_number: n, tip_content: "" });

export default function ProblemSolvingLessonEdit() {
  const { id } = useParams();
  const nav = useNavigate();

  const [submitting, setSubmitting] = useState(false);
  const [existingImages, setExistingImages] = useState([]);

  const [values, setValues] = useState({
    title: "",
    content: "",
    difficultyLevel: "Easy",
    correct_answer: "",
    catergory: "",
    tips: [emptyTip(1)],
    images: [],
  });

  const load = async () => {
    try {
      const res = await problemSolvingLessonService.getById(id);
      const lesson = res.data;

      setValues({
        title: lesson.title || "",
        content: lesson.content || "",
        difficultyLevel: lesson.difficultyLevel || "Easy",
        correct_answer: lesson.correct_answer || "",
        catergory: lesson.catergory || "",
        tips:
          lesson.tips?.length
            ? lesson.tips.map((t, idx) => ({ tip_number: idx + 1, tip_content: t.tip_content || "" }))
            : [emptyTip(1)],
        images: [],
      });

      setExistingImages((lesson.images || []).map((x) => x.image_url));
    } catch (e) {
      alert(e?.response?.data?.message || e.message);
    }
  };

  useEffect(() => {
    load();
  }, [id]);

  const onSubmit = async (e) => {
    e.preventDefault();

    if (!values.title.trim() || !values.difficultyLevel || !values.correct_answer.trim()) {
      alert("title, difficultyLevel, and correct_answer are required");
      return;
    }

    const cleanedTips = (values.tips || [])
      .map((t, i) => ({ tip_number: i + 1, tip_content: (t.tip_content || "").trim() }))
      .filter((t) => t.tip_content.length > 0);

    try {
      setSubmitting(true);
      await problemSolvingLessonService.update(id, {
        ...values,
        title: values.title.trim(),
        content: values.content.trim(),
        correct_answer: values.correct_answer.trim(),
        tips: cleanedTips,
      });

      nav(`/problem_solving_lessons/${id}`);
    } catch (e) {
      alert(e?.response?.data?.message || e.message);
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div style={{ maxWidth: 1000, margin: "0 auto", padding: 16 }}>
      <ProblemSolvingLessonForm
        mode="edit"
        values={values}
        setValues={setValues}
        onSubmit={onSubmit}
        submitting={submitting}
        existingImages={existingImages}
      />
    </div>
  );
}
