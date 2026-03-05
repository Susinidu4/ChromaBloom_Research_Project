import React, { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import { getChildByIdService } from '../../../services/childService';
import AdminLayout from './AdminLayout';

export const Child_information = () => {
  const { id } = useParams();
  const [child, setChild] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchChildData = async () => {
      try {
        const token = localStorage.getItem('token');
        const data = await getChildByIdService(id, token);
        setChild(data);
      } catch (err) {
        setError(err.response?.data?.message || 'Failed to fetch child information');
      } finally {
        setLoading(false);
      }
    };

    fetchChildData();
  }, [id]);

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      month: 'numeric',
      day: 'numeric',
      year: 'numeric'
    });
  };

  const calculateAge = (dateOfBirth) => {
    const birthDate = new Date(dateOfBirth);
    const today = new Date();
    let age = today.getFullYear() - birthDate.getFullYear();
    const monthDiff = today.getMonth() - birthDate.getMonth();
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }
    return age;
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-[#f5f0eb] flex justify-center items-center">
        <div className="text-lg text-[#8b7355]">Loading...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen bg-[#f5f0eb] flex justify-center items-center">
        <div className="text-lg text-red-600">{error}</div>
      </div>
    );
  }

  if (!child) {
    return (
      <div className="min-h-screen bg-[#f5f0eb] flex justify-center items-center">
        <div className="text-lg text-[#8b7355]">No child data found</div>
      </div>
    );
  }

  // Info row component
  const InfoRow = ({ label, value }) => (
    <div className="grid grid-cols-[160px_20px_1fr] items-baseline mb-4">
      <span className="text-[#A68972] text-[15px] font-medium">{label}</span>
      <span className="text-[#A68972] text-[15px]">:</span>
      <div className="border-b border-[#DBC7B8] pb-1">
        <span className="text-[#7A5C41] text-[15px] ml-1">{value || '-'}</span>
      </div>
    </div>
  );

  // Collapsible Section component
  const CollapsibleSection = ({ title, children }) => {
    const [isOpen, setIsOpen] = useState(true);

    return (
      <div className="mb-10">
        <div
          className="mb-6 cursor-pointer group"
          onClick={() => setIsOpen(!isOpen)}
        >
          <div className="flex items-center justify-between pb-1">
            <h3 className="text-[#8D6E63] font-bold text-[18px] tracking-tight">{title}</h3>
            <svg
              className={`w-6 h-6 text-[#A68972] transition-transform duration-300 ${isOpen ? '' : '-rotate-90'}`}
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M19 9l-7 7-7-7" />
            </svg>
          </div>
          <div className="border-b border-[#DBC7B8]"></div>
        </div>
        {isOpen && (
          <div className="pl-6 animate-fadeIn">
            {children}
          </div>
        )}
      </div>
    );
  };

  return (
    <AdminLayout>
      <div className="min-h-screen bg-[#F8EBE8] flex flex-col items-center py-12 px-4 relative font-sans">

        {/* Back Button */}
        <button
          className="absolute top-8 left-8 w-10 h-10 rounded-full bg-white shadow-[0_2px_10px_rgba(0,0,0,0.1)] flex items-center justify-center text-[#B08968] hover:bg-gray-50 transition-all hover:scale-105"
          onClick={() => window.history.back()}
        >
          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M15 19l-7-7 7-7" />
          </svg>
        </button>

        <div className="w-full max-w-2xl bg-[#FCF6F4]/50 backdrop-blur-sm border border-[#E6D5C7] rounded-[20px] p-10 mt-4 shadow-sm">

          {/* Parent Information Section */}
          <CollapsibleSection title="Parent Information">
            <InfoRow label="Name" value={child.caregiver?.full_name} />
            <InfoRow label="Gender" value={child.caregiver?.gender} />
            <InfoRow label="User Name" value={child.caregiver?.email} />
            <InfoRow label="Date of Birth" value={formatDate(child.caregiver?.dob)} />
            <InfoRow label="No of children" value={child.caregiver?.child_count?.toString()} />
          </CollapsibleSection>

          {/* Child Information Section */}
          <CollapsibleSection title="Child Information">
            <InfoRow label="Name" value={child.childName} />
            <InfoRow label="Date of Birth" value={formatDate(child.dateOfBirth)} />
            <InfoRow label="Gender" value={child.gender} />
            <InfoRow label="Height" value={`${child.heightCm} cm`} />
            <InfoRow label="Weight" value={`${child.weightKg} kg`} />
          </CollapsibleSection>

          {/* Medical Information Section */}
          <CollapsibleSection title="Medical Information">
            <InfoRow label="Down Syndrome Type" value={child.downSyndromeType} />
            <InfoRow label="DS Confirmed By" value={child.downSyndromeConfirmedBy} />
          </CollapsibleSection>

          {/* Other Health Conditions Section */}
          <CollapsibleSection title="Other Health Conditions">
            <InfoRow
              label="Heart issues"
              value={child.otherHealthConditions?.heartIssues ? 'Yes' : 'No'}
            />
            <InfoRow
              label="Thyroid"
              value={child.otherHealthConditions?.thyroid ? 'Yes' : 'No'}
            />
            <InfoRow
              label="Hearing Problems"
              value={child.otherHealthConditions?.hearingProblems ? 'Yes' : 'No'}
            />
            <InfoRow
              label="Vision Problems"
              value={child.otherHealthConditions?.visionProblems ? 'Yes' : 'No'}
            />
          </CollapsibleSection>

          {/* Other Information Section */}
          <CollapsibleSection title="Other Information">
            <InfoRow label="Created Date" value={formatDate(child.createdAt)} />
            <InfoRow label="Last Updated On" value={formatDate(child.updatedAt)} />
          </CollapsibleSection>

        </div>

        {/* Disable Patient Button */}
        <div className="w-full max-w-2xl flex justify-end mt-8">
          <button
            className="bg-[#5C1B11] text-white px-10 py-3 rounded-xl shadow-[0_4px_12px_rgba(92,27,17,0.3)] font-semibold text-sm hover:bg-[#4a160d] transition-all active:scale-95"
            onClick={() => {
              console.log('Toggle patient status');
            }}
          >
            {child.account_status === 'active' ? 'Disable Patient' : 'Enable Patient'}
          </button>
        </div>

      </div>
    </AdminLayout>
  );
};